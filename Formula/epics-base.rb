class EpicsBase < Formula
  desc "Distributed soft real-time control systems for scientific instruments such as a particle accelerators, telescopes and other large scientific experiments"
  homepage "https://epics-controls.org/"
  url "https://epics-controls.org/download/base/base-7.0.3.1.tar.gz"
  version "7.0.3.1"
  sha256 "1de65638a806be6c0eebc0b7840ed9dd1a1a7879bcb6ab0da88a1e8e456b709c"

  bottle do
    root_url "http://gallerihago.net/bottles"
    sha256 "992b90ac730264bf605645f637925a8928966f1b8176bb5ef16191c215622fcb" => :mojave
  end

  keg_only :provided_by_macos,
    "the EPICS build system does not lend itself particularly well to installing in a central system location"

  depends_on "re2c"

  depends_on "readline"

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    ENV["EPICS_BASE"] = prefix.to_s
    ENV["EPICS_HOST_ARCH"] = "darwin-x86"
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}"
    system "make"
  end

  # def post_install
  #  cd "#{prefix}/bin/darwin-x86" do
  #    bin.install %w[caget caput camonitor]
  #  end
  # end

  def caveats
    <<~EOS
      Installed EPICS #{version}. Recommended environment:
      export EPICS_BASE=#{opt_prefix}
      export EPICS_HOST_ARCH=darwin-x86
      export PATH=#{opt_bin}/$EPICS_HOST_ARCH:$PATH
    EOS
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    # Run the test with `brew test epics-base`.
    ENV["EPICS_BASE"] = prefix.to_s
    ENV["EPICS_HOST_ARCH"] = "darwin-x86"
    system "#{prefix}/bin/darwin-x86/caget", "-h"
    system "#{prefix}/bin/darwin-x86/caput", "-h"
    system "#{prefix}/bin/darwin-x86/pvget", "-h"

    (testpath/"test.cmd").write <<~EOS
            epicsPrtEnvParams
            # The trouble here is that we cant automatically exit the softIoc
            # so the whole test hangs here until user types exit...
            exit
      #{"    "}
    EOS

    # TODO: figure out how to not depend on user input on stdin
    # system "#{prefix}/bin/darwin-x86/softIoc", "#{testpath}/test.cmd"
    system "#{prefix}/bin/darwin-x86/makeBaseApp.pl", "-t", "example", "example"
    # system "#{prefix}/bin/darwin-x86/makeBaseApp.pl", "-i", "-t", "example", "example"
    system "make"
  end
end
