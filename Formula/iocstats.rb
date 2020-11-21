class Iocstats < Formula
  desc "support for records that show the health and status of an EPICS IOC, plus a few IOC control records"
  homepage "https://www.slac.stanford.edu/grp/ssrl/spear/epics/site/devIocStats/"
  url "https://github.com/epics-modules/iocStats/archive/3.1.16.tar.gz"
  version "3.1.16"
  sha256 "6270c83338cc4c339ffc31190aae30eb07eeb44daab3ca683706d8b061aa9e29"

  depends_on "epics-base"
  depends_on "seq"

  keg_only :provided_by_macos,
    "the EPICS build system does not lend itself particularly well to installing in a central system location"

  def install
    epics_base = Formula["epics-base"].opt_prefix
    ENV['EPICS_BASE'] = "#{epics_base}"
    ENV['EPICS_HOST_ARCH'] = "darwin-x86"

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    seq_prefix = Formula["seq"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*SNCSEQ\s*=.*$/, "SNCSEQ=#{seq_prefix}"
    inreplace "configure/RELEASE", /^SUPPORT=.*$/, "# removed unused SUPPORT macro"
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"

    # Build it
    system "make"

    # Install the UI screens as the EPICS build system doesn't do that by default
    opi = Pathname.new("#{prefix}/op")
    opi.mkpath
    opi.install Dir['op/*']

  end
end
