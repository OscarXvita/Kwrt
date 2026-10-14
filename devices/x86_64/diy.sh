#!/bin/bash

SHELL_FOLDER=$(dirname $(readlink -f "$0"))

#bash $SHELL_FOLDER/../common/kernel_6.6.sh

sed -i 's/Os/O2/g' include/target.mk

git_clone_path master https://github.com/coolsnowwolf/lede target/linux/x86/files target/linux/x86/patches-6.12

wget -N https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/x86/base-files/etc/board.d/02_network -P target/linux/x86/base-files/etc/board.d/
wget -N https://github.com/coolsnowwolf/lede/raw/refs/heads/master/target/linux/x86/Makefile -P target/linux/x86/
sed -i -e "s/ autocore-x86//" \
	   -e "s/ usb-net-rtl8152-vendor/usb-net-rtl8152/" \
       -e "s/ automount//" \
	   -e "s/6.18/6.12/" target/linux/x86/Makefile

sed -i 's/kmod-r8169/kmod-r8168/' target/linux/x86/image/64.mk

sed -i 's/256/1024/g' target/linux/x86/image/Makefile



# --- Hyper-V SR-IOV support ---
# ixgbevf (and other Hyper-V VF drivers) read their MAC through PCI config space,
# which needs CONFIG_PCI_MMCONFIG. Without it the VF gets a random MAC and
# Hyper-V reports "SR-IOV is not functional".
for f in target/linux/x86/64/config-*; do
	sed -i -e '/CONFIG_PCI_MMCONFIG[ =]/d' -e '/CONFIG_PCI_HYPERV[ =]/d' -e '/CONFIG_PCI_HYPERV_INTERFACE[ =]/d' "$f"
	printf 'CONFIG_PCI_MMCONFIG=y\nCONFIG_PCI_HYPERV=y\nCONFIG_PCI_HYPERV_INTERFACE=y\n' >> "$f"
done
