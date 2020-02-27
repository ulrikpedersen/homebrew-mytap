class Std < Formula
  desc "contains EPICS epid and scaler records and many OPI screens"
  homepage "https://github.com/epics-modules/std"
  url "https://github.com/epics-modules/std/archive/R3-6-1.tar.gz"
  version "3.6.1"
  sha256 "c88d4449d02510b5e493ee33a747b73fb80ad0a02f0445ae7c1790aec1b9b08a"

  depends_on "epics-base"
  depends_on "asyn"
  depends_on "seq"

  keg_only :provided_by_macos,
    "the EPICS build system does not lend itself particularly well to installing in a central system location"

  def install
    epics_base = Formula["epics-base"].opt_prefix
    ENV['EPICS_BASE'] = "#{epics_base}"
    ENV['EPICS_HOST_ARCH'] = "darwin-x86"

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    asyn_prefix = Formula["asyn"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*ASYN\s*=.*$/, "ASYN=#{asyn_prefix}"    
    seq_prefix = Formula["seq"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*SNCSEQ\s*=.*$/, "SNCSEQ=#{seq_prefix}"
    inreplace "configure/RELEASE", /^SUPPORT=.*$/, "# removed unused SUPPORT macro"
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"

    # Build it
    system "make"

    # Install the UI screens as the EPICS build system doesn't do that by default
    opi = Pathname.new("#{prefix}/stdApp/op")
    opi.mkpath
    opi.install Dir['stdApp/op/*']
  end
end
