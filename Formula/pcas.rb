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

  bottle do
    root_url "https://github.com/ulrikpedersen/homebrew-mytap/releases/download/pcas-4.13.2"
    sha256 cellar: :any, catalina:     "3074dc999ffc0b3257b268b9fe2aa90198fee0eb529a6cea79885c51b9611d88"
    sha256 cellar: :any, x86_64_linux: "4264fffd352d178f38f20414ac00e30a3f31fed26ce8e9811372e3677db24b4a"
  end

  keg_only "the EPICS build system does not lend itself to installing in a central system location"

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
