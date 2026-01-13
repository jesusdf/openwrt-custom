#!/bin/bash
if [ ! -d openwrt ]; then
    git clone https://git.openwrt.org/openwrt/openwrt.git
    cp netgear* openwrt/
fi
if [ -f 901-staging-mt7621-pci-delay-for-properly-detect.patch ]; then
    cd openwrt
fi
git checkout 4dd2e6ec5b81becd32dc25d85d977510d363a419
./scripts/feeds update -a
./scripts/feeds install -a
unset CFLAGS
unset CXXFLAGS
cp netgear-wac124-openwrt-config .config
make -j$(getconf _NPROCESSORS_ONLN) V=sc defconfig download clean world && cd bin/targets/ramips/mt7621 && ls
