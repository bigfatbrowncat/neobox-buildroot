################################################################################
#
# mingw-w64-headers
#
################################################################################

MINGW_W64_HEADERS_VERSION = v11.0.0
MINGW_W64_HEADERS_SOURCE = mingw-w64-$(MINGW_W64_HEADERS_VERSION).tar.bz2
#MINGW_W64_HEADERS_SITE = http://downloads.sourceforge.net/project/haserl/haserl-devel
#MINGW_W64_HEADERS_SITE = http://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v3.1.0.tar.bz2
MINGW_W64_HEADERS_SITE = http://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/
MINGW_W64_HEADERS_LICENSE = LGPL-2.0
MINGW_W64_HEADERS_LICENSE_FILES = COPYING
#MINGW_W64_HEADERS_CPE_ID_VENDOR = haserl_project
MINGW_W64_HEADERS_DEPENDENCIES = host-pkgconf
MINGW_W64_HEADERS_SUBDIR = mingw-w64-headers

HOST_MINGW_W64_HEADERS_CONF_ENV = CC="x86_64-w64-mingw32-gcc" CXX="x86_64-w64-mingw32-g++" CPP="x86_64-w64-mingw32-cpp" AS="x86_64-w64-mingw32-as"

HOST_MINGW_W64_HEADERS_CONF_OPTS = \
        --host=x86_64-w64-mingw32 \
        --build=${GNU_HOST_NAME} \
        --prefix=$(HOST_DIR)/mingw \
        --with-sysroot=$(HOST_DIR)/mingw \
        --enable-lib64 \
        --disable-lib32 \
        --disable-multilib



#	--host=x86_64-w64-mingw32 \
#	--target=x86_64-w64-mingw32 \
#	--prefix=$(HOST_DIR)/x86_64-w64-mingw32

#HOST_MINGW_W64_HEADERS_CONF_ENV = \
#        $(HOST_GCC_MINGW_COMMON_CONF_ENV)


$(eval $(autotools-package))
$(eval $(host-autotools-package))
