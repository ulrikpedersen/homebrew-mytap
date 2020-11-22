class EpicsBase < Formula
  desc "Experimental Physics and Industrial Control System (EPICS)"
  homepage "https://epics-controls.org/"
  url "https://epics-controls.org/download/base/base-7.0.3.1.tar.gz"
  # version "7.0.3.1"
  sha256 "1de65638a806be6c0eebc0b7840ed9dd1a1a7879bcb6ab0da88a1e8e456b709c"

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

  def caveats
    <<~EOS
      Installed EPICS #{version}. Recommended environment:
      export EPICS_BASE=#{opt_prefix}/top
      export EPICS_HOST_ARCH=#{epics_host_arch}
      export PATH=#{opt_bin}/$EPICS_HOST_ARCH:$PATH
    EOS
  end
end
