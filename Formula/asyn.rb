class Asyn < Formula
  desc "Provides asynchronous support to the EPICS distributed control system"
  homepage "https://epics-modules.github.io/master/asyn"
  url "https://github.com/epics-modules/asyn/archive/R4-38.tar.gz"
  version "4.38"
  sha256 "1da2df85370e87d9654fd4c13b0510f9f81cc7b761adbd950c1d151cdb815a12"

  keg_only :provided_by_macos,
    "the EPICS build system does not lend itself particularly well to installing in a central system location"

  depends_on "epics-base"
  depends_on "seq"

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    epics_base = Formula["epics-base"].opt_prefix
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = "darwin-x86"

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    seq_prefix = Formula["seq"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*SNCSEQ\s*=.*$/, "SNCSEQ=#{seq_prefix}"
    inreplace "configure/RELEASE", /^IPAC=.*$/, "# removed unused dep on IPAC"
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"
    system "make"
  end
end
