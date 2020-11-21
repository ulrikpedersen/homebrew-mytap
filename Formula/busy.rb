class Busy < Formula
  desc "Contains the  record, which allows CA clients to indicate completion in a way that works with EPICS putNotify/ca_put_callback mechanism"
  homepage "https://epics.anl.gov/bcda/synApps/busy/busy.html"
  url "https://github.com/epics-modules/busy/archive/R1-7-2.tar.gz"
  version "1.7.2"
  sha256 "cc92faae0361ce86dbf319cc50e59ecff0a9dfbb3b04a6102c9b6f9e58cce36f"

  keg_only :provided_by_macos,
    "the EPICS build system does not lend itself particularly well to installing in a central system location"

  depends_on "asyn"

  depends_on "epics-base"

  def install
    epics_base = Formula["epics-base"].opt_prefix
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = "darwin-x86"

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    asyn_prefix = Formula["asyn"].opt_prefix
    inreplace "configure/RELEASE", /^#?\s*ASYN\s*=.*$/, "ASYN=#{asyn_prefix}"
    inreplace "configure/RELEASE", /^SUPPORT=.*$/, "# removed unused SUPPORT macro"
    inreplace "configure/RELEASE", /^AUTOSAVE=.*$/, "# removed unused AUTOSAVE macro"
    inreplace "configure/RELEASE", /^BUSY=.*$/, "# removed unused BUSY macro"
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"

    # Build it
    system "make"

    # Install the UI screens as the EPICS build system doesn't do that by default
    opi = Pathname.new("#{prefix}/busyApp/op")
    opi.mkpath
    opi.install Dir["busyApp/op/*"]
  end
end
