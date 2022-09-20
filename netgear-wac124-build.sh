#!/bin/bash
sudo apt update
sudo apt install build-essential gawk gcc-multilib flex git gettext libncurses5-dev libssl-dev python3-distutils rsync unzip zlib1g-dev clang
git clone https://git.openwrt.org/openwrt/openwrt.git
cp netgear* openwrt/
rm openwrt/target/linux/generic/backport-*/411-*-mtd-parsers-add-support-for-Sercomm-partitions.patch
rm openwrt/target/linux/generic/pending-*/435-mtd-add-routerbootpart-parser-config.patch
cd openwrt
# Latest commit when this repository was built: https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=f4ca4187cde01a3e412f10657bec0790d3a4cd94
git checkout f4ca4187cde01a3e412f10657bec0790d3a4cd94
./scripts/feeds update -a
./scripts/feeds install -a
cat netgear-partition-badblocks.patch | patch -p1
cp netgear-wac124-openwrt-config .config
make -j12 menuconfig
# Ensure that the custom packages are selected (like ntpclient on Network\Time Synchronization) and continue with the kernel compilation:
make -j12 kernel_menuconfig
cp netgear-wac124-kernel-config build_dir/target-mipsel_24kc_musl/linux-ramips_mt7621/linux-5.10.143/.config
make -j12 kernel_menuconfig
# Ensure that the following options in the kernel configuration, and save it:
# <*> General setup\Kernel .config support
# [*] General setup\Enable access to .config through /proc/config.gz
# <*> Device Drivers\Memory Technology Device (MTD) support -->\Partition parsers\Sercomm partition table parser
make -j12 defconfig download clean world
# If it fails, add the following parameter to have a verbose output: V=sc

