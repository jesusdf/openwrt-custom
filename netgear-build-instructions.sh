#!/bin/bash
sudo apt update
sudo apt install build-essential gawk gcc-multilib flex git gettext libatomic\* libncurses5-dev libssl-dev devscripts intltool python3-distutils-extra rsync unzip zlib1g-dev clang python3-unidecode
git clone https://git.openwrt.org/openwrt/openwrt.git
cp netgear* openwrt/
#cp 901-staging-mt7621-pci-delay-for-properly-detect.patch openwrt/target/linux/ramips/patches-5.15/
#rm openwrt/target/linux/generic/backport-*/411-*-mtd-parsers-add-support-for-Sercomm-partitions.patch
#rm openwrt/target/linux/generic/pending-*/435-mtd-add-routerbootpart-parser-config.patch
cd openwrt
# Latest commit when this repository was built: https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=4dd2e6ec5b81becd32dc25d85d977510d363a419
git checkout 4dd2e6ec5b81becd32dc25d85d977510d363a419
./scripts/feeds update -a
./scripts/feeds install -a
unset CFLAGS
unset CXXFLAGS
make -j$(getconf _NPROCESSORS_ONLN) menuconfig
# Exit without saving
# Patch is already upstream, this is not needed anymore:
# https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=77692d6112074f969170ec3c9b353df6565bc1c3
# cat netgear-partition-badblocks.patch | patch -p1
# For Netgear WAC124
cp netgear-wac124-openwrt-config .config
# For Netgear R6260
#cp netgear-r6260-openwrt-config .config
make -j$(getconf _NPROCESSORS_ONLN) menuconfig
# Ensure that the custom packages are selected (like ntpdate on Network\Time Synchronization)
# and continue with the kernel compilation:
make -j$(getconf _NPROCESSORS_ONLN) kernel_menuconfig
# Exit without saving
cp netgear-kernel-config build_dir/target-mipsel_24kc_musl/linux-ramips_mt7621/linux-6.12.63/.config
make -j$(getconf _NPROCESSORS_ONLN) kernel_menuconfig
# Ensure that the following options are selected in the kernel configuration, and save it:
# <*> General setup\Kernel .config support
# [*] General setup\Enable access to .config through /proc/config.gz
# <*> Device Drivers\Memory Technology Device (MTD) support -->\Partition parsers\Sercomm partition table parser
make -j$(getconf _NPROCESSORS_ONLN) defconfig download clean world && cd bin/targets/ramips/mt7621 && ls
# If it works, the built image and packages will be located in the bin folder.
# If it fails, add the following parameter to have a verbose output: V=sc
