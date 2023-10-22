################################################################################
#
# mpc-mingw
#
################################################################################

MPC_MINGW_VERSION = 1.2.1
MPC_MINGW_SITE = $(BR2_GNU_MIRROR)/mpc
MPC_MINGW_SOURCE = mpc-$(MPC_MINGW_VERSION).tar.gz
MPC_MINGW_LICENSE = LGPL-3.0+
MPC_MINGW_LICENSE_FILES = COPYING.LESSER
MPC_MINGW_INSTALL_STAGING = YES
MPC_MINGW_DEPENDENCIES = gmp-mingw mpfr-mingw
HOST_MPC_MINGW_DEPENDENCIES = host-gmp-mingw host-mpfr-mingw

HOST_MPC_MINGW_CONF_ENV += \
	CC="x86_64-w64-mingw32-gcc" \
	CXX="x86_64-w64-mingw32-g++"

HOST_MPC_MINGW_CONF_OPTS += \
	--host=x86_64-w64-mingw32 \
	--enable-static --disable-shared

$(eval $(autotools-package))
$(eval $(host-autotools-package))
