class EpicsBase < Formula
  desc "Experimental Physics and Industrial Control System (EPICS)"
  homepage "https://epics-controls.org/"
  url "https://epics-controls.org/download/base/base-7.0.6.1.tar.gz"
  # version "7.0.6.1"
  sha256 "8ff318f25e2b70df466f933636a2da85e4b0c841504b9e89857652a4786b6387"
  license "EPICS"
  # revision 1

  keg_only "the EPICS build system does not lend itself particularly well to installing in a central system location"

  depends_on "make"
  depends_on "re2c"
  depends_on "readline"

  # Create a function epics_host_arch that will return the
  # appropriate EPICS host architecture definition on either
  # MacOS or Linux. To be used for setting EPICS_HOST_ARCH
  # environment variable.
  on_macos do
    if Hardware::CPU.arm?
      def epics_host_arch
        "darwin-aarch64"
      end
    end
    if Hardware::CPU.intel?
      def epics_host_arch
        "darwin-x86"
      end
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

  # We need a fairly recent version of make for EPICS builds
  # so use homebrew installed gmake
  def make_cmd
    gmake_bin_dir = Formula["make"].opt_bin.to_s
    if OS.mac?
      "#{gmake_bin_dir}/gmake"
    else
      "#{gmake_bin_dir}/make"
    end
  end

  def install
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s
    File.write("configure/CONFIG_SITE.local", "INSTALL_LOCATION=#{prefix}/top")
    system make_cmd, "install"
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
      Use (g)make from homebrew to build modules and IOCs: #{make_cmd}
      export PATH=#{Formula["make"].opt_bin.to_s}:$PATH

      Installed EPICS #{version}. Recommended environment:
      export EPICS_BASE=#{epics_base}
      export EPICS_HOST_ARCH=#{epics_host_arch}
      export PATH=#{epics_base}/bin/$EPICS_HOST_ARCH:$PATH
    EOS
  end

  test do
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s
    shell_output("#{epics_base}/bin/#{epics_host_arch}/caget BLAH", result=1)
    system "#{epics_base}/bin/#{epics_host_arch}/caget", "-h"
    system "#{epics_base}/bin/#{epics_host_arch}/caput", "-h"
    system "#{epics_base}/bin/#{epics_host_arch}/pvget", "-h"
  end
end
