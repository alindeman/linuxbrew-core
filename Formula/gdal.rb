class Gdal < Formula
  desc "Geospatial Data Abstraction Library"
  homepage "https://www.gdal.org/"
  url "https://download.osgeo.org/gdal/2.4.2/gdal-2.4.2.tar.xz"
  sha256 "dcc132e469c5eb76fa4aaff238d32e45a5d947dc5b6c801a123b70045b618e0c"
  revision OS.mac? ? 5 : 6

  bottle do
    sha256 "7ab5d0645e315c69694dcf2b75e398d92c2bb85a6a52c6e52447e676c58d2230" => :catalina
    sha256 "c1e5a07f9d38a004e739355015a52f1ca4623fc16e4dbac3c115e5579cce0d37" => :mojave
    sha256 "0d7dd3e1382f657b6e70bdd8d4cea6cb266768836b36d83357df26b85dd5ee15" => :high_sierra
  end

  head do
    url "https://github.com/OSGeo/gdal.git"
    depends_on "doxygen" => :build
  end

  depends_on "cfitsio"
  depends_on "epsilon"
  depends_on "expat"
  depends_on "freexl"
  depends_on "geos"
  depends_on "giflib"
  depends_on "hdf5"
  depends_on "jasper"
  depends_on "jpeg"
  depends_on "json-c"
  depends_on "libdap"
  depends_on "libgeotiff"
  depends_on "libpng"
  depends_on "libpq"
  depends_on "libspatialite"
  depends_on "libtiff"
  depends_on "libxml2"
  depends_on "netcdf"
  depends_on "numpy"
  depends_on "pcre"
  depends_on "poppler"
  depends_on "proj"
  depends_on "python"
  depends_on "sqlite" # To ensure compatibility with SpatiaLite
  depends_on "unixodbc" # macOS version is not complete enough
  depends_on "webp"
  depends_on "xerces-c"
  depends_on "xz" # get liblzma compression algorithm library from XZutils
  depends_on "zstd"

  unless OS.mac?
    depends_on "pkg-config" => :build
    depends_on "bash-completion"
  end
  conflicts_with "cpl", :because => "both install cpl_error.h"

  def install
    # Fixes: error: inlining failed in call to always_inline __m128i _mm_shuffle_epi8
    ENV.append_to_cflags "-msse4.1" if ENV["CI"]

    unless OS.mac?
      # The python build needs libgdal.so, which is located in .libs
      ENV.append "LDFLAGS", "-L#{buildpath}/.libs"
      # The python build needs gnm headers, which are located in the gnm folder
      ENV.append "CFLAGS", "-I#{buildpath}/gnm"
    end

    args = [
      # Base configuration
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--with-libtool",
      "--with-local=#{prefix}",
      "--with-threads",

      # GDAL native backends
      "--with-bsb",
      "--with-grib",
      "--with-pam",
      "--with-pcidsk=internal",
      "--with-pcraster=internal",

      # Homebrew backends
      "--with-expat=#{Formula["expat"].prefix}",
      "--with-freexl=#{Formula["freexl"].opt_prefix}",
      "--with-geos=#{Formula["geos"].opt_prefix}/bin/geos-config",
      "--with-geotiff=#{Formula["libgeotiff"].opt_prefix}",
      "--with-gif=#{Formula["giflib"].opt_prefix}",
      "--with-jpeg=#{Formula["jpeg"].opt_prefix}",
      "--with-libjson-c=#{Formula["json-c"].opt_prefix}",
      "--with-libtiff=#{Formula["libtiff"].opt_prefix}",
      "--with-pg=#{Formula["libpq"].opt_prefix}/bin/pg_config",
      "--with-png=#{Formula["libpng"].opt_prefix}",
      "--with-spatialite=#{Formula["libspatialite"].opt_prefix}",
      "--with-sqlite3=#{Formula["sqlite"].opt_prefix}",
      "--with-proj=#{Formula["proj"].opt_prefix}",
      "--with-zstd=#{Formula["zstd"].opt_prefix}",
      "--with-liblzma=yes",
      "--with-cfitsio=#{Formula["cfitsio"].opt_prefix}",
      "--with-hdf5=#{Formula["hdf5"].opt_prefix}",
      "--with-netcdf=#{Formula["netcdf"].opt_prefix}",
      "--with-jasper=#{Formula["jasper"].opt_prefix}",
      "--with-xerces=#{Formula["xerces-c"].opt_prefix}",
      "--with-odbc=#{Formula["unixodbc"].opt_prefix}",
      "--with-dods-root=#{Formula["libdap"].opt_prefix}",
      "--with-epsilon=#{Formula["epsilon"].opt_prefix}",
      "--with-webp=#{Formula["webp"].opt_prefix}",
      "--with-poppler=#{Formula["poppler"].opt_prefix}",

      # Explicitly disable some features
      "--with-armadillo=no",
      "--with-qhull=no",
      "--without-grass",
      "--without-jpeg12",
      "--without-libgrass",
      "--without-mysql",
      "--without-perl",
      "--without-python",
      # Unsupported backends are either proprietary or have no compatible version
      # in Homebrew. Podofo is disabled because Poppler provides the same
      # functionality and then some.
      "--without-gta",
      "--without-ogdi",
      "--without-fme",
      "--without-hdf4",
      "--without-openjpeg",
      "--without-fgdb",
      "--without-ecw",
      "--without-kakadu",
      "--without-mrsid",
      "--without-jp2mrsid",
      "--without-mrsid_lidar",
      "--without-msg",
      "--without-oci",
      "--without-ingres",
      "--without-idb",
      "--without-sde",
      "--without-podofo",
      "--without-rasdaman",
      "--without-sosi",
    ]

    if OS.mac?
      args << "--with-curl=/usr/bin/curl-config"
    else
      args << "--with-curl=#{Formula["curl"].opt_bin}/curl-config"
      args << "--with-libz=#{Formula["zlib"].opt_prefix}"
    end

    # Work around "error: no member named 'signbit' in the global namespace"
    # Remove once support for macOS 10.12 Sierra is dropped
    if DevelopmentTools.clang_build_version >= 900
      ENV.delete "SDKROOT"
      ENV.delete "HOMEBREW_SDKROOT"
    end

    system "./configure", *args
    system "make"
    system "make", "install"

    # Build Python bindings
    cd "swig/python" do
      system "python3", *Language::Python.setup_install_args(prefix)
    end
    bin.install Dir["swig/python/scripts/*.py"]

    system "make", "man" if build.head?
    # Force man installation dir: https://trac.osgeo.org/gdal/ticket/5092
    system "make", "install-man", "INST_MAN=#{man}"
    # Clean up any stray doxygen files
    Dir.glob("#{bin}/*.dox") { |p| rm p }
  end

  test do
    # basic tests to see if third-party dylibs are loading OK
    system "#{bin}/gdalinfo", "--formats"
    system "#{bin}/ogrinfo", "--formats"
    system "python3", "-c", "import gdal"
  end
end
