class Seq < Formula
  desc "Provides EPICS with sequencer and State Notation Language (SNL) support"
  homepage "https://www-csr.bessy.de/control/SoftDist/sequencer/index.html"
  url "https://www-csr.bessy.de/control/SoftDist/sequencer/releases/seq-2.2.8.tar.gz"
  # version "2.2.8"
  sha256 "f19e982d46ed467ba8604de346cac838ea27eef39462fe6ae429dc49f338a794"

  bottle do
    root_url "https://github.com/ulrikpedersen/homebrew-mytap/releases/download/seq-2.2.8"
    sha256 "d775381128f788e22b90ee0aceecfaae0475bc3222cf5c25d564baea1309b4ee" => :catalina
    sha256 "f3212176f36d28da5b746c32a6d15f9ca2bc069e06c0e0165501ba5d94b9f87b" => :x86_64_linux
  end

  keg_only :provided_by_macos,
    "the EPICS build system does not lend itself particularly well to installing in a central system location"

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
    system "make"
  end

  test do
    ENV["EPICS_BASE"] = Formula["epics-base"].epics_base
    ENV["EPICS_HOST_ARCH"] = Formula["epics-base"].epics_host_arch
    # TODO: what can we do for testing here?
  end
end
