class Autosave < Formula
  desc "Store EPICS PV values to files which can be restored on IOC reboot"
  homepage "https://epics.anl.gov/bcda/synApps/autosave/autosave.html"
  url "https://github.com/epics-modules/autosave/archive/R5-10.tar.gz"
  version "5.10"
  sha256 "3f4f27283b34c5798cc9ab27d38c7191e963b0bac82cb1680a6dccddac57f48c"

  keg_only :provided_by_macos,
    "the EPICS build system does not lend itself particularly well to installing in a central system location"

  depends_on "epics-base"

  def install
    epics_base = Formula["epics-base"].opt_prefix
    epics_host_arch = Formula["epics-base"].epics_host_arch
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    # inreplace "configure/RELEASE", /^SUPPORT=.*$/, "# removed unused SUPPORT macro"
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"

    # Build it
    system "make"

    # Install the UI screens as the EPICS build system doesn't do that by default
    opi = Pathname.new("#{prefix}/asApp/op")
    opi.mkpath
    opi.install Dir["asApp/op/*"]
  end
end
