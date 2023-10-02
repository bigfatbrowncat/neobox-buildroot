#!/bin/sh

#[ -z "$1" ] || [ "x$1" = "xstart" ] || exit 0

SWAP_PERCENT_MEM=80
SWAPPINESS=20
#SWAP_COMPRESSOR=lzo-rle

# User overrides.
[ -r /usr/local/etc/swap.conf ] && . /usr/local/etc/swap.conf

#[ $SWAP_PERCENT_MEM -gt 0 ] || return 0

psplash_write "Setup swap..."

#modprobe -q zram

SWAP_FILE_MB=$(expr $(sed -n 's/MemTotal: \+\([[:digit:]]\+\).*/\1/p' /proc/meminfo) \* ${SWAP_PERCENT_MEM} / 102400)
#SWAP_FILE=$(zramctl -a ${SWAP_COMPRESSOR} -s ${SWAP_FILE_MB}M -f)

echo $SWAPPINESS > /proc/sys/vm/swappiness

SWAP_FILE=/media/data/swapfile

# Enable swap file
if [ ! -f "${SWAP_FILE}" ] ; then
	psplash_write "Creating swap file..."
	dd if=/dev/zero of=${SWAP_FILE} bs=${SWAP_FILE_MB} count=1048576
	mkswap ${SWAP_FILE}
fi

if [ -f "${SWAP_FILE}" ] ; then
	psplash_write "Enabling swap..."
	swapon ${SWAP_FILE}
fi
