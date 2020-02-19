class EpicsBase < Formula
  desc "a distributed soft real-time control systems for scientific instruments such as a particle accelerators, telescopes and other large scientific experiments"
  homepage "https://epics.anl.gov"
  url "https://github.com/epics-base/epics-base/archive/R7.0.3.1.tar.gz"
  version "7.0.3.1"
  sha256 "33521511226eead16cb06075cd14336d6715cf8e1b899a11ec70f81f7c7c48b6"

  depends_on "readline"
  depends_on "re2c"
  
  keg_only :provided_by_macos,
    "the EPICS build system does not lend itself particularly well to installing in a central system location"

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    ENV['EPICS_BASE'] = "#{prefix}"
    ENV['EPICS_HOST_ARCH'] = "darwin-x86"
    inreplace "configure/CONFIG_SITE", /.*INSTALL_LOCATION=.*/, "INSTALL_LOCATION=#{prefix}"
    system "make"
  end

  #def post_install
  #  cd "#{prefix}/bin/darwin-x86" do
  #    bin.install %w[caget caput camonitor]
  #  end
  #end

def caveats
  s = <<~EOS
    Installed EPICS #{version}. Recommended environment:
    export EPICS_BASE=#{opt_prefix}
    export EPICS_HOST_ARCH=darwin-x86
    export PATH=#{opt_bin}/$EPICS_HOST_ARCH:$PATH
  EOS
  s
end

  test do
    # `test do` will create, run in and delete a temporary directory.
    # Run the test with `brew test epics-base`. 
    ENV['EPICS_BASE'] = "#{prefix}"
    ENV['EPICS_HOST_ARCH'] = "darwin-x86"
    system "#{prefix}/bin/darwin-x86/caget", "-h"
    system "#{prefix}/bin/darwin-x86/caput", "-h"

    (testpath/"test.cmd").write <<~EOS
      epicsPrtEnvParams
      # The trouble here is that we cant automatically exit the softIoc
      # so the whole test hangs here until user types exit...
      exit
    
    EOS

    # TODO: figure out how to not depend on user input on stdin
    #system "#{prefix}/bin/darwin-x86/softIoc", "#{testpath}/test.cmd"
    system "#{prefix}/bin/darwin-x86/makeBaseApp.pl", "-t", "example", "example"
    #system "#{prefix}/bin/darwin-x86/makeBaseApp.pl", "-i", "-t", "example", "example"
    system "make"
  end
end
