class Seq < Formula
  desc "Provides EPICS with sequencer and State Notation Language (SNL) support"
  homepage "https://www-csr.bessy.de/control/SoftDist/sequencer/index.html"
  url "https://www-csr.bessy.de/control/SoftDist/sequencer/releases/seq-2.2.9.tar.gz"
  # version "2.2.9"
  sha256 "a2fdba045bcbf5f8949ab9b6ebf9a8766cbfc8737afd67fe5fca1ed7b9881398"
  # Revision 1: Removed :provided_by_macros arg to keg_only
  # revision 1

  keg_only "the EPICS build system does not lend itself particularly well to installing in a central system location"

  depends_on "make"
  depends_on "epics-base"
  depends_on "re2c"

  def install
    epics_base = Formula["epics-base"].epics_base
    epics_host_arch = Formula["epics-base"].epics_host_arch
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    re2c_bindir = Formula["re2c"].opt_bin
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}/top"
    inreplace "configure/CONFIG_SITE", /^#?\s*RE2C\s*=.*$/, "RE2C=#{re2c_bindir}/re2c"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"
    system Formula["epics-base"].make_cmd, "install"
  end

  test do
    ENV["EPICS_BASE"] = Formula["epics-base"].epics_base
    ENV["EPICS_HOST_ARCH"] = Formula["epics-base"].epics_host_arch
    # TODO: what can we do for testing here?
  end
end
