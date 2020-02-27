class Autosave < Formula
  desc "contains software to store EPICS Process Variables values to files which can be restored on ioc reboot"
  homepage "https://epics.anl.gov/bcda/synApps/autosave/autosave.html"
  url "https://github.com/epics-modules/autosave/archive/R5-10.tar.gz"
  version "5.10"
  sha256 "3f4f27283b34c5798cc9ab27d38c7191e963b0bac82cb1680a6dccddac57f48c"

  depends_on "epics-base"

  keg_only :provided_by_macos,
    "the EPICS build system does not lend itself particularly well to installing in a central system location"

  def install
    epics_base = Formula["epics-base"].opt_prefix
    ENV['EPICS_BASE'] = "#{epics_base}"
    ENV['EPICS_HOST_ARCH'] = "darwin-x86"

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    #inreplace "configure/RELEASE", /^SUPPORT=.*$/, "# removed unused SUPPORT macro"
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"

    # Build it
    system "make"

    # Install the UI screens as the EPICS build system doesn't do that by default
    opi = Pathname.new("#{prefix}/asApp/op")
    opi.mkpath
    opi.install Dir['asApp/op/*']
  end
end
