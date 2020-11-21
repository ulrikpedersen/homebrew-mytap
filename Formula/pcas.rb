class Pcas < Formula
  desc "Contains support for run-time expression evaluation, similar to calcPostfix, in EPICS base, but extended to handle strings, arrays, and additional numeric operations"
  homepage "https://github.com/epics-modules/pcas"
  url "https://github.com/epics-modules/pcas/archive/v4.13.2.tar.gz"
  version "4.13.2"
  sha256 "7ff1dd052d6df97141c68fb4fc26f8a4337c7d133114012295bb5c2bfa8d2a59"

  keg_only :provided_by_macos,
    "the EPICS portable channel access server"

  depends_on "epics-base"

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    epics_base = Formula["epics-base"].opt_prefix
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = "darwin-x86"

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"
    system "make"
  end
end
