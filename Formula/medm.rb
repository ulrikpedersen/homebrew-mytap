class Medm < Formula
  desc "the EPICS Display Manager"
  homepage "https://epics.anl.gov/extensions/medm/index.php"
  url "https://github.com/epics-extensions/medm/archive/MEDM3_1_14.tar.gz"
  version "3.1.14"
  sha256 "b87c3f85288e535de1e8e3708172e04bb55b16a8d38cfd56fbe6b2ed69b41d04"

  depends_on "epics-base"
  depends_on "openmotif"
  depends_on :x11

  patch :DATA

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    epics_base = Formula["epics-base"].opt_prefix
    ENV['EPICS_BASE'] = "#{epics_base}"
    ENV['EPICS_HOST_ARCH'] = "darwin-x86"

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    motif_prefix = Formula["openmotif"].opt_prefix
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}"
    system "make"
    bin.install Dir["#{bin}/darwin-x86/*"]
  end
end
__END__
diff --git a/Makefile b/Makefile
index 5402592..01a51b4 100644
--- a/Makefile
+++ b/Makefile
@@ -8,9 +8,9 @@
 #*************************************************************************
 # Makefile for medm top level
 
-TOP = ../..
+TOP = .
 include $(TOP)/configure/CONFIG
 DIRS = printUtils xc medm
-include $(TOP)/configure/RULES_DIRS
+include $(TOP)/configure/RULES_TOP
 
 medm_DEPEND_DIRS = printUtils xc
diff --git a/configure/CONFIG b/configure/CONFIG
new file mode 100644
index 0000000..04418f6
--- /dev/null
+++ b/configure/CONFIG
@@ -0,0 +1,48 @@
+# $Id$
+
+# You might want to change this to some shared set of rules, e.g.
+# RULES=/path/to/epics/support/modules/rules/x-y
+RULES=$(EPICS_BASE)
+
+INSTALL_IDLFILE = $(INSTALL)
+
+include $(TOP)/configure/RELEASE
+-include $(TOP)/configure/RELEASE.$(EPICS_HOST_ARCH)
+ifdef T_A
+-include $(TOP)/configure/RELEASE.Common.$(T_A)
+-include $(TOP)/configure/RELEASE.$(EPICS_HOST_ARCH).Common
+-include $(TOP)/configure/RELEASE.$(EPICS_HOST_ARCH).$(T_A)
+endif
+
+CONFIG=$(RULES)/configure
+include $(CONFIG)/CONFIG
+
+# Override for definition in base
+INSTALL_LOCATION = $(TOP)
+include $(TOP)/configure/CONFIG_SITE
+
+ifdef INSTALL_LOCATION_EXTENSIONS
+INSTALL_LOCATION = $(INSTALL_LOCATION_EXTENSIONS)
+endif
+
+#  Site specific host architecture definitions
+-include $(TOP)/configure/os/CONFIG_SITE.$(EPICS_HOST_ARCH).Common
+
+ifdef T_A
+
+#  Site specific target architecture definitions
+-include $(TOP)/configure/os/CONFIG_SITE.Common.$(T_A)
+
+#  Cross compile specific definitions
+ifneq ($(EPICS_HOST_ARCH),$(T_A))
+-include $(TOP)/configure/CONFIG.CrossCommon
+endif
+
+#  Site specific host-target combination definitions
+-include $(TOP)/configure/os/CONFIG.$(EPICS_HOST_ARCH).$(T_A)
+-include $(TOP)/configure/os/CONFIG_SITE.$(EPICS_HOST_ARCH).$(T_A)
+
+-include $(TOP)/configure/O.$(T_A)/CONFIG_APP_INCLUDE
+
+endif
+
diff --git a/configure/CONFIG_SITE b/configure/CONFIG_SITE
new file mode 100644
index 0000000..99b355f
--- /dev/null
+++ b/configure/CONFIG_SITE
@@ -0,0 +1,26 @@
+# $Id$
+#
+# Make any extensions-specific changes to the EPICS build
+# configuration variables in this file.
+#
+# Host/target specific settings are in os subdirectory files named
+#  os/CONFIG_SITE.$(EPICS_HOST_ARCH).Common
+#  os/CONFIG_SITE.Common.$(T_A)
+#  os/CONFIG_SITE.$(EPICS_HOST_ARCH).$(T_A)
+
+# Extensions are not normally built for cross targets
+CROSS_COMPILER_TARGET_ARCHS =
+
+# If you don't want to install into $(TOP) then
+# define INSTALL_LOCATION here
+#INSTALL_LOCATION=<fullpathname>
+
+# Extensions don't normally build shared libraries
+SHARED_LIBRARIES = NO
+
+# These allow developers to override the CONFIG_SITE variable
+# settings without having to modify the configure/CONFIG_SITE
+# file itself.
+-include $(TOP)/../CONFIG_SITE.local
+-include $(TOP)/configure/CONFIG_SITE.local
+
diff --git a/configure/Makefile b/configure/Makefile
new file mode 100644
index 0000000..5b1e45a
--- /dev/null
+++ b/configure/Makefile
@@ -0,0 +1,10 @@
+# $Id$
+
+TOP=..
+
+include $(TOP)/configure/CONFIG
+
+TARGETS = $(CONFIG_TARGETS)
+
+include $(TOP)/configure/RULES
+
diff --git a/configure/RELEASE b/configure/RELEASE
new file mode 100644
index 0000000..6f29558
--- /dev/null
+++ b/configure/RELEASE
@@ -0,0 +1,33 @@
+# $Id$
+#
+#RELEASE Location of external products
+#
+# NOTE: The build does not check dependancies on files
+# external to this application. Thus you should run
+# "gnumake clean uninstall install" in the top directory
+# each time EPICS_BASE, SNCSEQ, or any other external
+# module defined in a RELEASE* file is rebuilt.
+#
+# Host/target specific settings can be specified in files named
+#  RELEASE.$(EPICS_HOST_ARCH).Common
+#  RELEASE.Common.$(T_A)
+#  RELEASE.$(EPICS_HOST_ARCH).$(T_A)
+
+# Define INSTALL_LOCATION in CONFIG_SITE
+
+# Location of external products
+
+# Location of external products
+EPICS_BASE=$(TOP)/../base
+#EPICS_EXTENSIONS = /usr/local/epics/extensions
+EPICS_EXTENSIONS=$(TOP)
+
+OAG_APPS=$(TOP)/../../oag/apps
+
+
+
+# These allow developers to override the RELEASE variable settings
+# without having to modify the configure/RELEASE file itself.
+-include $(TOP)/../RELEASE.local
+-include $(TOP)/configure/RELEASE.local
+
diff --git a/configure/RELEASE.local b/configure/RELEASE.local
new file mode 100644
index 0000000..e6187d9
--- /dev/null
+++ b/configure/RELEASE.local
@@ -0,0 +1,2 @@
+EPICS_BASE=/usr/local/opt/epics-base
+
diff --git a/configure/RELEASE.win32-x86 b/configure/RELEASE.win32-x86
new file mode 100644
index 0000000..2f745b6
--- /dev/null
+++ b/configure/RELEASE.win32-x86
@@ -0,0 +1,10 @@
+# $Id$
+
+# If you don't want to install into $(TOP) dir then
+# define INSTALL_LOCATION_EXTENSIONS here
+#INSTALL_LOCATION_EXTENSIONS=<fullpathname>
+
+# Location of external products
+EPICS_BASE=G:/epics/base
+EPICS_EXTENSIONS = G:/epics/extensions
+
diff --git a/configure/RULES b/configure/RULES
new file mode 100644
index 0000000..c2c1034
--- /dev/null
+++ b/configure/RULES
@@ -0,0 +1,3 @@
+# $Id$
+
+include $(CONFIG)/RULES
diff --git a/configure/RULES_DIRS b/configure/RULES_DIRS
new file mode 100644
index 0000000..4e7a45b
--- /dev/null
+++ b/configure/RULES_DIRS
@@ -0,0 +1,3 @@
+# $Id$
+
+include $(CONFIG)/RULES_DIRS
diff --git a/configure/RULES_TOP b/configure/RULES_TOP
new file mode 100644
index 0000000..d24f6bb
--- /dev/null
+++ b/configure/RULES_TOP
@@ -0,0 +1,4 @@
+# $Id$
+
+include $(CONFIG)/RULES_TOP
+
diff --git a/configure/os/CONFIG_SITE.Common.Common b/configure/os/CONFIG_SITE.Common.Common
new file mode 100644
index 0000000..07b4b74
--- /dev/null
+++ b/configure/os/CONFIG_SITE.Common.Common
@@ -0,0 +1,12 @@
+#
+# $Id$
+#
+# Site Specific Configuration Information
+# Only the local epics system manager should modify this file
+
+# java jdk definitions
+#CLASSPATH += -classpath .:..:$(INSTALL_JAVA):$(JAVA_DIR)/bin/../classes:$(JAVA_DIR)/bin/../lib/classes.zip
+#JAVACCMD = $(subst \,/,$(JAVA_DIR)/bin/javac$(EXE) $(CLASSPATH) $(JAVAC_FLAGS) )
+#JAVAHCMD = $(subst \,/,$(JAVA_DIR)/bin/javah$(EXE) -jni $(CLASSPATH) $(JAVAH_FLAGS))
+#JARCMD = $(subst \,/,$(JAVA_DIR)/bin/jar$(EXE) $(JAR_OPTIONS) $(MANIFEST) $(JAR) $(JAR_INPUT))
+
diff --git a/configure/os/CONFIG_SITE.darwin-x86.darwin-x86 b/configure/os/CONFIG_SITE.darwin-x86.darwin-x86
new file mode 100644
index 0000000..366cd02
--- /dev/null
+++ b/configure/os/CONFIG_SITE.darwin-x86.darwin-x86
@@ -0,0 +1,100 @@
+#
+# $Id$
+#
+# Site Specific Configuration Information
+# Only the local epics system manager should modify this file
+
+# Where to find utilities/libraries
+#       If you do not have a certain product,
+#       leave the line empty.
+#
+
+-include $(TOP)/configure/os/CONFIG_SITE.Common.Common
+-include $(TOP)/configure/os/CONFIG_SITE.Common.darwinCommon
+
+#PYTHON_DIR=/usr/lib/python2.2
+#PYTHON_INCLUDE=/System/Library/Frameworks/Python.framework/Versions/2.3/include/python2.3
+
+# Following 3 for SDDS
+#USE_GD_LIBRARY=1
+#USE_RUNCONTROL=1
+#USE_LOGDAEMON=1
+
+# Where to find utilities/libraries
+#  If you do not have a certain product,
+#  leave the line empty.
+#
+
+#
+# XDarwin
+#
+#X11_LIB=/usr/X11R6/lib
+#X11_INC=/usr/X11R6/include
+#XPM_LIB=/usr/X11R6/lib
+#XPM_INC=/usr/X11R6/include
+
+#
+# Fink OpenMotif
+#
+#MOTIF_LIB=/sw/lib
+#MOTIF_INC=/sw/include
+
+#
+# DarwinPorts OpenMotif
+#
+#MOTIF_LIB=/opt/local/lib
+#MOTIF_INC=/opt/local/include
+#
+# DarwinPorts X11
+#
+#X11_LIB=/opt/local/lib
+#X11_INC=/opt/local/include
+
+# 
+# homebrew openmotif an xquartz:
+#   brew cask install xquartz
+#   brew install openmotif
+MOTIF_LIB=/usr/local/opt/openmotif/lib
+MOTIF_INC=/usr/local/opt/openmotif/include
+X11_LIB=/opt/X11/lib
+X11_INC=/opt/X11/include
+XPM_LIB=/opt/X11/lib
+XPM_INC=/opt/X11/include
+
+#
+# Interviews
+#
+IV_INC=
+IV-2_6_INC=
+IV_BIN=
+IV_LIB=
+
+OPENWIN = 
+WINGZ_INC =
+WINGZ_LIB =
+MATHEMATICA = 
+
+# Define XRTGRAPH_EXTENSIONS = YES only if using XRT/graph 3.x
+#   and you want the extensions for MEDM
+#XRTGRAPH_EXTENSIONS = YES
+#XRTGRAPH = /opt/local/xrtgraph
+
+SCIPLOT = YES
+QUESTWIN = 
+
+#TK_LIB = /sw/lib
+#TK_INC = /sw/include
+#TCL_LIB = /sw/lib
+#TCL_INC = /sw/include
+#DP_LIB = /sw/lib
+#DP_INC = /sw/include
+#BLT_LIB = /sw/lib
+#BLT_INC = /sw/include
+
+#
+# Preliminary JAVA support
+#
+#JAVA_DIR=/System/Library/Frameworks/JavaVM.framework/Home
+#JAVA_INC=/System/Library/Frameworks/JavaVM.framework/Headers
+#JAVA_INCLUDES = -I$(JAVA_INC)
+
diff --git a/medm/Makefile b/medm/Makefile
index 007ec46..4f3e1ef 100644
--- a/medm/Makefile
+++ b/medm/Makefile
@@ -9,7 +9,7 @@
 #
 # $Id$
 #
-TOP = ../../..
+TOP = ..
 include $(TOP)/configure/CONFIG
 
 # Motif
@@ -176,10 +176,10 @@ USR_LIBS_Linux = Xm Xt Xp Xmu X11 Xext
 
 USR_LIBS_cygwin32 = Xm Xt Xmu X11 Xext SM ICE
 USR_LIBS_Darwin = -nil-
-PROD_SYS_LIBS_Darwin = Xt Xmu X11 Xext Xft Xp fontconfig png
+PROD_SYS_LIBS_Darwin = Xt Xmu X11 Xext Xft Xp fontconfig png iconv Xm
 
 #Do not use PROD_LDFLAGS_Darwin because it goes after OP_SYS_LDFLAGS
-USR_LDFLAGS_Darwin = -L/usr/X11/lib /opt/local/lib/libXm.a /opt/local/lib/libjpeg.a /opt/local/lib/libiconv.a
+USR_LDFLAGS_Darwin = -L$(X11_LIB) /usr/local/lib/libjpeg.a 
 
 WIN32_RUNTIME=MD
 USR_CFLAGS_WIN32 += /DWIN32 /D_WINDOWS
@@ -196,8 +196,7 @@ Xext_DIR = $(X11_LIB)
 Xft_DIR = $(X11_LIB)
 fontconfig_DIR = $(X11_LIB)
 png_DIR = $(X11_LIB)
-jpeg_DIR = $(MOTIF_LIB)
-iconv_DIR = $(MOTIF_LIB)
+jpeg_DIR = /usr/local/lib
 
 SRCS += actions.c
 SRCS += bubbleHelp.c
diff --git a/printUtils/Makefile b/printUtils/Makefile
index edeafff..35ca1b2 100644
--- a/printUtils/Makefile
+++ b/printUtils/Makefile
@@ -9,7 +9,7 @@
 #
 # $Id$
 #
-TOP = ../../..
+TOP = ..
 include $(TOP)/configure/CONFIG
 
 SHARED_LIBRARIES = NO
diff --git a/xc/Makefile b/xc/Makefile
index 6473c2b..e2a6b85 100644
--- a/xc/Makefile
+++ b/xc/Makefile
@@ -9,7 +9,7 @@
 #
 # $Id$
 #
-TOP = ../../..
+TOP = ..
 include $(TOP)/configure/CONFIG
 
 SHARED_LIBRARIES = NO
