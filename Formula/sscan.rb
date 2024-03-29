class Sscan < Formula
  desc "EPICS sscan record"
  homepage "https://epics.anl.gov/bcda/synApps/sscan/sscan.html"
  url "https://github.com/epics-modules/sscan/archive/R2-11-3.tar.gz"
  version "2.11.3"
  sha256 "dcd883900fbf4b8b46ed03a952e76731b873a96b07d457089cdabbe55b955e65"

  bottle do
    root_url "https://github.com/ulrikpedersen/homebrew-mytap/releases/download/sscan-2.11.3"
    sha256 cellar: :any, catalina:     "3b2efc1701d61c4f7254d247f017f2a559aad2a94e35f0893dd17f2abe2e9e31"
    sha256 cellar: :any, x86_64_linux: "452325e90cd1ee25179000ecaf380813f04faed2644295cc87cebda94c5adf9f"
  end

  keg_only "the EPICS build system does not lend itself particularly well to installing in a central system location"

  depends_on "epics-base"
  depends_on "seq"

  def install
    epics_base = Formula["epics-base"].epics_base
    epics_host_arch = Formula["epics-base"].epics_host_arch
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    seq_prefix = Formula["seq"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*SNCSEQ\s*=.*$/, "SNCSEQ=#{seq_prefix}/top"
    inreplace "configure/RELEASE", /^#?\s*SUPPORT\s*=.*$/, "# removed unused SUPPORT macro"
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}/top"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"

    system "make"

    opi = Pathname.new("#{prefix}/sscanApp/op")
    opi.mkpath
    opi.install Dir["sscanApp/op/*"]
  end

  test do
    ENV["EPICS_BASE"] = Formula["epics-base"].epics_base
    ENV["EPICS_HOST_ARCH"] = Formula["epics-base"].epics_host_arch
    # TODO: what can we do for testing sscan here?
  end
end
