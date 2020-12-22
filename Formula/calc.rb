class Calc < Formula
  desc "EPICS Calc record enables run-time expression evaluation"
  homepage "https://epics.anl.gov/bcda/synApps/calc/calc.html"
  url "https://github.com/epics-modules/calc/archive/R3-7-3.tar.gz"
  version "3.7.3"
  sha256 "c1b18410275f6f03494cda4b7ab23b64520327ed65931f38f3230e25b75ae3c2"

  keg_only "the EPICS build system does not lend itself particularly well to installing in a central system location"
  # Also the 'calc' name conflicts with another Homebrew formula.

  depends_on "epics-base"
  depends_on "seq"

  def install
    epics_base = Formula["epics-base"].epics_base
    epics_host_arch = Formula["epics-base"].epics_host_arch
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    seq_prefix = Formula["seq"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*SNCSEQ\s*=.*$/, "SNCSEQ=#{seq_prefix}/top"
    inreplace "configure/RELEASE", /^SSCAN=.*$/, "# removed unused dep on SSCAN"
    inreplace "configure/RELEASE", /^#?\s*SUPPORT\s*=.*$/, "# removed unused SUPPORT macro"
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}/top"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"

    system "make"

    # Install the UI screens as the EPICS build system doesn't do that by default
    opi = Pathname.new("#{prefix}/top/calcApp/op")
    opi.mkpath
    opi.install Dir["calcApp/op/*"]
  end

  test do
    ENV["EPICS_BASE"] = Formula["epics-base"].epics_base
    ENV["EPICS_HOST_ARCH"] = Formula["epics-base"].epics_host_arch
    # TODO: what can we do for testing calc here?
  end
end
