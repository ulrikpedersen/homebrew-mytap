class Busy < Formula
  desc "EPICS busy record enables CA clients to indicate completion via ca_put_callback"
  homepage "https://epics.anl.gov/bcda/synApps/busy/busy.html"
  url "https://github.com/epics-modules/busy/archive/R1-7-2.tar.gz"
  version "1.7.2"
  sha256 "cc92faae0361ce86dbf319cc50e59ecff0a9dfbb3b04a6102c9b6f9e58cce36f"

  bottle do
    root_url "https://github.com/ulrikpedersen/homebrew-mytap/releases/download/busy-1.7.2"
    cellar :any
    sha256 "2eeb13e362c165549a2517c154a0923e2633702494e4cc3075e3910f32999334" => :catalina
    sha256 "01752e1c6e6a6d5a74ef2c23068ac393efa51e4f8a34c1e8a6e302ea8fe55116" => :x86_64_linux
  end

  keg_only "the EPICS build system does not lend itself particularly well to installing in a central system location"

  depends_on "asyn"

  depends_on "epics-base"

  def install
    epics_base = Formula["epics-base"].epics_base
    epics_host_arch = Formula["epics-base"].epics_host_arch
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    asyn_prefix = Formula["asyn"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*ASYN\s*=.*$/, "ASYN=#{asyn_prefix}/top"
    inreplace "configure/RELEASE", /^SUPPORT=.*$/, "# removed unused SUPPORT macro"
    inreplace "configure/RELEASE", /^AUTOSAVE=.*$/, "# removed unused AUTOSAVE macro"
    inreplace "configure/RELEASE", /^BUSY=.*$/, "# removed unused BUSY macro"
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}/top"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"

    # Build it
    system "make"

    # Install the UI screens as the EPICS build system doesn't do that by default
    opi = Pathname.new("#{prefix}/top/busyApp/op")
    opi.mkpath
    opi.install Dir["busyApp/op/*"]
  end

  test do
    ENV["EPICS_BASE"] = Formula["epics-base"].epics_base
    ENV["EPICS_HOST_ARCH"] = Formula["epics-base"].epics_host_arch
    # TODO: what can we do for testing busy here?
  end
end
