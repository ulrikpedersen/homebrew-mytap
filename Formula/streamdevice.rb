class Streamdevice < Formula
  desc "EPICS device support for byte stream based communication interfaces"
  homepage "https://paulscherrerinstitute.github.io/StreamDevice/"
  url "https://github.com/paulscherrerinstitute/StreamDevice/archive/2.8.10.tar.gz"
  # version "2.8.10"
  sha256 "5836df5f7569f2e153e0d0df2f5a40961c5804aef6f7f37f6409ec70f4fa336c"

  bottle do
    root_url "https://github.com/ulrikpedersen/homebrew-mytap/releases/download/streamdevice-2.8.10"
    sha256 catalina:     "9185892270a3af991ed882b32868fa3548d8616a45687b519e57bb68baf44516"
    sha256 x86_64_linux: "cfa445a7136ebd1eff49abd90a65adbc0d85b2a8f652270e33608111990ad1fe"
  end

  keg_only "the EPICS build system does not work by installing in a central system location"

  depends_on "asyn"
  depends_on "epics-base"
  depends_on "pcre"
  depends_on "ulrikpedersen/mytap/calc"

  def install
    epics_base = Formula["epics-base"].epics_base
    epics_host_arch = Formula["epics-base"].epics_host_arch
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    asyn_prefix = Formula["asyn"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*ASYN\s*=.*$/, "ASYN=#{asyn_prefix}/top"
    calc_prefix = Formula["calc"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*CALC\s*=.*$/, "CALC=#{calc_prefix}/top"
    pcre_prefix = Formula["pcre"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*PCRE\s*=.*$/, "#PCRE=#{pcre_prefix}"
    inreplace "configure/RELEASE", /^#?\s*SUPPORT\s*=.*$/, "# removed unused SUPPORT macro"
    inreplace "configure/RELEASE", /^#?\s*INSTALL_LOCATION_APP\s*=.*$/, "INSTALL_LOCATION_APP=#{prefix}/top"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"

    # Build it
    system "make"
  end

  test do
    ENV["EPICS_BASE"] = Formula["epics-base"].epics_base
    ENV["EPICS_HOST_ARCH"] = Formula["epics-base"].epics_host_arch
    # TODO: what can we do for testing streamdevice here?
  end
end
