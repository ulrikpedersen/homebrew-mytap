class Std < Formula
  desc "Contains EPICS epid and scaler records and many OPI screens"
  homepage "https://github.com/epics-modules/std"
  url "https://github.com/epics-modules/std/archive/R3-6-1.tar.gz"
  version "3.6.1"
  sha256 "c88d4449d02510b5e493ee33a747b73fb80ad0a02f0445ae7c1790aec1b9b08a"

  bottle do
    root_url "https://github.com/ulrikpedersen/homebrew-mytap/releases/download/std-3.6.1"
    sha256 catalina:     "2497770482087bea527e02463f9a7ba8e2c1dd4965adb40eeec530118cc2acaa"
    sha256 x86_64_linux: "cadb3d7ba2626e5d89ec32afff3aad608fea5837ddbc017b23ac1f8c3063e463"
  end

  keg_only "the EPICS build system does not lend itself particularly well to installing in a central system location"

  depends_on "asyn"
  depends_on "epics-base"
  depends_on "seq"

  def install
    epics_base = Formula["epics-base"].epics_base
    epics_host_arch = Formula["epics-base"].epics_host_arch
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    asyn_prefix = Formula["asyn"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*ASYN\s*=.*$/, "ASYN=#{asyn_prefix}/top"
    seq_prefix = Formula["seq"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*SNCSEQ\s*=.*$/, "SNCSEQ=#{seq_prefix}/top"
    inreplace "configure/RELEASE", /^#?\s*SUPPORT\s*=.*$/, "# removed unused SUPPORT macro"
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}/top"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"

    # Build it
    system "make"

    # Install the UI screens as the EPICS build system doesn't do that by default
    opi = Pathname.new("#{prefix}/stdApp/op")
    opi.mkpath
    opi.install Dir["stdApp/op/*"]
  end

  test do
    ENV["EPICS_BASE"] = Formula["epics-base"].epics_base
    ENV["EPICS_HOST_ARCH"] = Formula["epics-base"].epics_host_arch
    # TODO: what can we do for testing std here?
  end
end
