################################################################################
#
# ninja-mingw
#
################################################################################

NINJA_MINGW_VERSION_MAJOR = 1.11.1
NINJA_MINGW_VERSION = $(NINJA_VERSION_MAJOR).g95dee.kitware.jobserver-1
NINJA_MINGW_SITE = $(call github,Kitware,ninja,v$(NINJA_VERSION))
NINJA_MINGW_LICENSE = Apache-2.0
NINJA_MINGW_LICENSE_FILES = COPYING

HOST_NINJA_MINGW_DEPENDENCIES = host-gcc-to-mingw-final
HOST_NINJA_MINGW_CONF_OPTS = \
        -DCMAKE_C_COMPILER=$(HOST_DIR)/bin/x86_64-w64-mingw32-gcc \
        -DCMAKE_CXX_COMPILER=$(HOST_DIR)/bin/x86_64-w64-mingw32-g++ \
        -DBUILD_SHARED_LIBS=OFF -DMINGW=ON -DWIN32=ON

define HOST_NINJA_MINGW_INSTALL_CMDS
	$(INSTALL) -m 0755 -D $(@D)/ninja.exe $(O)/host/bin/ninja.exe
endef

$(eval $(host-cmake-package))
