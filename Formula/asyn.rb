class Asyn < Formula
  desc "Provides asynchronous support to the EPICS distributed control system"
  homepage "https://epics-modules.github.io/master/asyn"
  url "https://github.com/epics-modules/asyn/archive/R4-42.tar.gz"
  version "4.42"
  sha256 "bbd83add5a977a1668a74684cba7ffd1637fc5de8c687ce9360bc3e25304d501"
  license "EPICS"
  # revision 1

  keg_only "the EPICS build system does not lend itself particularly well to installing in a central system location"

  depends_on "make"
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
    inreplace "configure/RELEASE", /^#?\s*IPAC\s*=.*$/, "# removed unused dep on IPAC"
    inreplace "configure/RELEASE", /^#?\s*SUPPORT\s*=.*$/, "# removed unused SUPPORT macro"
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}/top"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"

    # build away
    system Formula["epics-base"].make_cmd, "install"

    # Install the UI screens as the EPICS build system doesn't do that by default
    opi = Pathname.new("#{prefix}/top/opi")
    opi.mkpath
    opi.install Dir["opi/*"]
  end

  test do
    ENV["EPICS_BASE"] = Formula["epics-base"].epics_base
    ENV["EPICS_HOST_ARCH"] = Formula["epics-base"].epics_host_arch
    # TODO: what can we do for testing asyn here?
  end
end
