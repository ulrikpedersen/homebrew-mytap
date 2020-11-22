class EpicsBase < Formula
  desc "Experimental Physics and Industrial Control System (EPICS)"
  homepage "https://epics-controls.org/"
  url "https://epics-controls.org/download/base/base-7.0.3.1.tar.gz"
  # version "7.0.3.1"
  sha256 "1de65638a806be6c0eebc0b7840ed9dd1a1a7879bcb6ab0da88a1e8e456b709c"
  # Revisions:
  # 1: fixed issue with installing executables directly into opt_bin
  revision 1

  bottle do
    root_url "https://github.com/ulrikpedersen/homebrew-mytap/releases/download/epics-base-7.0.3.1"
    sha256 "1f254b030dd736aa4bbaa7bfffd39b8f54de2f0dd75c69f90d5b6fc807fc3c9f" => :catalina
    sha256 "c8d6580287be8422158eab95d304b2134653b30ef0c7be7f9ae5b401755cd35f" => :x86_64_linux
  end

  keg_only :provided_by_macos,
    "the EPICS build system does not lend itself particularly well to installing in a central system location"

  depends_on "re2c"

  depends_on "readline"

  # Create a function epics_host_arch that will return the
  # appropriate EPICS host architecture definition on either
  # MacOS or Linux. To be used for setting EPICS_HOST_ARCH
  # environment variable.
  on_macos do
    def epics_host_arch
      "darwin-x86"
    end
  end
  on_linux do
    def epics_host_arch
      "linux-x86_64"
    end
  end

  def epics_base
    "#{opt_prefix}/top"
  end

  def install
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}/top"
    system "make"
  end

  # The post install step we used to install executables into the prefix/bin dir.
  # However, that turns out to be more confusing than helpful and often don't work
  # at all because some executables expect to find themselves in prefix/bin/<arch>/ dir.
  # def post_install
  #   bin.mkpath
  #   ln_s Dir.glob("#{prefix}/top/bin/#{epics_host_arch}/*"), bin.to_s, verbose: true
  # end

  def caveats
    <<~EOS
      Installed EPICS #{version}. Recommended environment:
      export EPICS_BASE=#{epics_base}
      export EPICS_HOST_ARCH=#{epics_host_arch}
      export PATH=#{epics_base}/bin/$EPICS_HOST_ARCH:$PATH
    EOS
  end

  test do
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s
    system "#{epics_base}/bin/#{epics_host_arch}/caget", "-h"
    system "#{epics_base}/bin/#{epics_host_arch}/caput", "-h"
    system "#{epics_base}/bin/#{epics_host_arch}/pvget", "-h"
  end
end
