class Streamdevice < Formula
  desc "is a generic EPICS device support for devices with a byte stream based communication interface"
  homepage "https://paulscherrerinstitute.github.io/StreamDevice/"
  url "https://github.com/paulscherrerinstitute/StreamDevice/archive/2.8.10.tar.gz"
  version "2.8.10"
  sha256 "5836df5f7569f2e153e0d0df2f5a40961c5804aef6f7f37f6409ec70f4fa336c"

  depends_on "epics-base"
  depends_on "asyn"
  depends_on "ulrikpedersen/mytap/calc"
  depends_on "pcre"

  keg_only :provided_by_macos,
    "the EPICS build system does not lend itself particularly well to installing in a central system location"

  def install
    epics_base = Formula["epics-base"].opt_prefix
    ENV['EPICS_BASE'] = "#{epics_base}"
    ENV['EPICS_HOST_ARCH'] = "darwin-x86"

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    asyn_prefix = Formula["asyn"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*ASYN\s*=.*$/, "ASYN=#{asyn_prefix}"    
    calc_prefix = Formula["calc"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*CALC\s*=.*$/, "CALC=#{calc_prefix}"
    pcre_prefix = Formula["pcre"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*PCRE\s*=.*$/, "#PCRE=#{pcre_prefix}" 
    inreplace "configure/RELEASE", /^SUPPORT=.*$/, "# removed unused SUPPORT macro"
    inreplace "configure/RELEASE", /^#?\s*INSTALL_LOCATION_APP\s*=.*$/, "INSTALL_LOCATION_APP=#{prefix}"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"

    # Build it
    system "make"
  end
end
