class Pcas < Formula
  desc "Portable Channel Access Server (PCAS)"
  homepage "https://github.com/epics-modules/pcas"
  head "https://github.com/epics-modules/pcas.git"
  
  stable do
    url "https://github.com/epics-modules/pcas/archive/v4.13.2.tar.gz"
    # version "4.13.2"
    sha256 "7ff1dd052d6df97141c68fb4fc26f8a4337c7d133114012295bb5c2bfa8d2a59"
  
    # Patch required for version 4.13.2 but a fix is already present on the main branch
    # of pcas upstream and is expected to be included in the next release. This patch
    # can be removed when version > 4.13.2
    patch do
      url "https://github.com/epics-modules/pcas/commit/56403e8e4774dccc3819cab27bc975f48ab5f988.patch?full_index=1"
      sha256 "380932c7f9d1148cb8b6f4ad4ee56c8ddc362c1c68b3329d155dfdc4a5602719"
    end
  end

  keg_only "the EPICS build system does not lend itself particularly well to installing in a central system location"

  depends_on "epics-base"

  def install
    epics_base = Formula["epics-base"].epics_base
    epics_host_arch = Formula["epics-base"].epics_host_arch
    ENV["EPICS_BASE"] = epics_base.to_s
    ENV["EPICS_HOST_ARCH"] = epics_host_arch.to_s

    # EPICS 'configure' step is to edit files in the configure/ dir to point to dependencies, etc.
    inreplace "configure/CONFIG_SITE", /^#?\s*INSTALL_LOCATION\s*=.*$/, "INSTALL_LOCATION=#{prefix}/top"
    inreplace "configure/RELEASE", /^EPICS_BASE\s*=.*/, "EPICS_BASE=#{epics_base}"
    system "make"
  end

  test do
    ENV["EPICS_BASE"] = Formula["epics-base"].epics_base
    ENV["EPICS_HOST_ARCH"] = Formula["epics-base"].epics_host_arch
    # TODO: what can we do for testing pcas here?
  end
end
