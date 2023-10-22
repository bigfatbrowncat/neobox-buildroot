################################################################################
#
# mpfr-mingw
#
################################################################################

MPFR_MINGW_VERSION = 4.1.1
MPFR_MINGW_SITE = http://www.mpfr.org/mpfr-$(MPFR_MINGW_VERSION)
MPFR_MINGW_SOURCE = mpfr-$(MPFR_MINGW_VERSION).tar.xz
MPFR_MINGW_LICENSE = LGPL-3.0+
MPFR_MINGW_LICENSE_FILES = COPYING.LESSER
MPFR_MINGW_CPE_ID_VENDOR = gnu
MPFR_MINGW_INSTALL_STAGING = YES
MPFR_MINGW_DEPENDENCIES = gmp-mingw
HOST_MPFR_MINGW_DEPENDENCIES = host-gmp-mingw
MPFR_MINGW_MAKE_OPTS = RANLIB=$(TARGET_RANLIB)

HOST_MPFR_MINGW_CONF_ENV += \
	CC="x86_64-w64-mingw32-gcc" \
	CXX="x86_64-w64-mingw32-g++"

HOST_MPFR_MINGW_CONF_OPTS += \
	--host=x86_64-w64-mingw32 \
	--enable-static --disable-shared

$(eval $(autotools-package))
$(eval $(host-autotools-package))
