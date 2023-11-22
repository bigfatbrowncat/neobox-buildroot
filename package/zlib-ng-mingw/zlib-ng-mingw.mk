################################################################################
#
# zlib-ng-mingw
#
################################################################################

ZLIB_NG_MINGW_VERSION = 2.0.6
ZLIB_NG_MINGW_SITE = $(call github,zlib-ng,zlib-ng,$(ZLIB_NG_MINGW_VERSION))
ZLIB_NG_MINGW_LICENSE = Zlib
ZLIB_NG_MINGW_LICENSE_FILES = LICENSE.md
#ZLIB_NG_MINGW_INSTALL_STAGING = YES
#ZLIB_NG_MINGW_PROVIDES = zlib

HOST_ZLIB_NG_MINGW_DEPENDENCIES = host-gcc-to-mingw-final
# Build with zlib compatible API, gzFile support and optimizations on
HOST_ZLIB_NG_MINGW_CONF_OPTS += \
	-DWITH_GZFILEOP=1 \
	-DWITH_OPTIM=1 \
	-DZLIB_COMPAT=1 \
	-DZLIB_ENABLE_TESTS=OFF \
        -DCMAKE_C_COMPILER=$(HOST_DIR)/bin/x86_64-w64-mingw32-gcc \
        -DCMAKE_CXX_COMPILER=$(HOST_DIR)/bin/x86_64-w64-mingw32-g++ \
	-DCMAKE_RC_COMPILER=$(HOST_DIR)/bin/x86_64-w64-mingw32-windres \
        -DBUILD_SHARED_LIBS=ON -DMINGW=ON -DWIN32=ON \
        -DCMAKE_EXECUTABLE_SUFFIX=.exe \
	-DHAVE_OFF64_T=ON

define HOST_ZLIB_NG_MINGW_INSTALL_CMDS
        $(INSTALL) -m 0755 -D $(@D)/libzlib1.dll $(O)/host/bin/zlib1.dll
endef

$(eval $(host-cmake-package))
