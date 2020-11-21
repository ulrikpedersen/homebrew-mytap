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

  on_macos do
    epics_host_arch "darwin-x86"
  end
  on_linux do
    epics_host_arch "linux-x86_64"
  end

  def install
    ENV["EPICS_BASE"] = prefix.to_s
    # ENV["EPICS_HOST_ARCH"] = system "sh startup/EpicsHostArch"
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}"
    system "make"
  end

  # def post_install
  #  cd "#{prefix}/bin/#{epics_host_arch}" do
  #    bin.install %w[caget caput camonitor]
  #  end
  # end

  def caveats
    <<~EOS
      Installed EPICS #{version}. Recommended environment:
      export EPICS_BASE=#{opt_prefix}
      export EPICS_HOST_ARCH=#{epics_host_arch}
      export PATH=#{opt_bin}/$EPICS_HOST_ARCH:$PATH
    EOS
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    # Run the test with `brew test epics-base`.
    ENV["EPICS_BASE"] = prefix.to_s
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s
    system "#{bin}/#{epics_host_arch}/caget", "-h"
    system "#{bin}/#{epics_host_arch}/caput", "-h"
    system "#{bin}/#{epics_host_arch}/pvget", "-h"

    (testpath/"test.cmd").write <<~EOS
            epicsPrtEnvParams
            # The trouble here is that we cant automatically exit the softIoc
            # so the whole test hangs here until user types exit...
            exit
      #{"    "}
    EOS

    # TODO: figure out how to not depend on user input on stdin
    # system "#{prefix}/bin/#{epics_host_arch}/softIoc", "#{testpath}/test.cmd"
    system "#{bin}/#{epics_host_arch}/makeBaseApp.pl", "-t", "example", "example"
    # system "#{bin}/#{epics_host_arch}/makeBaseApp.pl", "-i", "-t", "example", "example"
    system "make"
  end
end
