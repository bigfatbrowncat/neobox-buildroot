################################################################################
#
# gmp-mingw
#
################################################################################

GMP_MINGW_VERSION = 6.2.1
GMP_MINGW_SITE = $(BR2_GNU_MIRROR)/gmp
GMP_MINGW_SOURCE = gmp-$(GMP_MINGW_VERSION).tar.xz
GMP_MINGW_INSTALL_STAGING = YES
GMP_MINGW_LICENSE = LGPL-3.0+ or GPL-2.0+
GMP_MINGW_LICENSE_FILES = COPYING.LESSERv3 COPYINGv2
GMP_MINGW_CPE_ID_VENDOR = gmplib
GMP_MINGW_DEPENDENCIES = host-m4
HOST_GMP_MINGW_DEPENDENCIES = host-m4 host-gcc-to-mingw-final

#HOST_GMP_MINGW_INSTALL_STAGING = YES

# 0001-mpz-inp_raw.c-Avoid-bit-size-overflows.patch
GMP_MINGW_IGNORE_CVES += CVE-2021-43618


HOST_GMP_MINGW_CONF_ENV += \
	CC="x86_64-w64-mingw32-gcc" \
	CXX="x86_64-w64-mingw32-g++"

HOST_GMP_MINGW_CONF_OPTS += \
	--host=x86_64-w64-mingw32 \
	--enable-static --disable-shared

#	--prefix="$(HOST_DIR)/mingw-prefix"
#	--enable-static --disable-shared \
#	--build=$(GNU_HOST_NAME) \
#	--static-libgcc \

# GMP doesn't support assembly for coldfire or mips r6 ISA yet
# Disable for ARM v7m since it has different asm constraints
ifeq ($(BR2_m68k_cf)$(BR2_MIPS_CPU_MIPS32R6)$(BR2_MIPS_CPU_MIPS64R6)$(BR2_ARM_CPU_ARMV7M),y)
GMP_MINGW_CONF_OPTS += --disable-assembly
endif

ifeq ($(BR2_INSTALL_LIBSTDCPP),y)
GMP_MINGW_CONF_OPTS += --enable-cxx
else
GMP_MINGW_CONF_OPTS += --disable-cxx
endif

#define HOST_GMP_MINGW_INSTALL_STAGING_CMDS
#        $(STAGING_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(HOST_DIR)/mingw-prefix install
#endef

$(eval $(autotools-package))
$(eval $(host-autotools-package))
