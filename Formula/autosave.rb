class Autosave < Formula
  desc "Store EPICS PV values to files which can be restored on IOC reboot"
  homepage "https://epics.anl.gov/bcda/synApps/autosave/autosave.html"
  url "https://github.com/epics-modules/autosave/archive/R5-10.tar.gz"
  version "5.10"
  sha256 "3f4f27283b34c5798cc9ab27d38c7191e963b0bac82cb1680a6dccddac57f48c"
  # Revision 1: Removed :provided_by_macros arg to keg_only
  # revision 1

  keg_only "the EPICS build system does not lend itself particularly well to installing in a central system location"

  depends_on "make" => :build
  depends_on "epics-base"

  def install
    epics_base = Formula["epics-base"].epics_base
    epics_host_arch = Formula["epics-base"].epics_host_arch
    module_top = "#{prefix}/top"
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    # inreplace "configure/RELEASE", /^SUPPORT=.*$/, "# removed unused SUPPORT macro"
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{module_top}"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"

    # Build it
    system Formula["epics-base"].make_cmd

    # Install the UI screens as the EPICS build system doesn't do that by default
    opi = Pathname.new("#{module_top}/asApp/op")
    opi.mkpath
    opi.install Dir["asApp/op/*"]
  end

  test do
    ENV["EPICS_BASE"] = Formula["epics-base"].epics_base
    ENV["EPICS_HOST_ARCH"] = Formula["epics-base"].epics_host_arch
  end
end
