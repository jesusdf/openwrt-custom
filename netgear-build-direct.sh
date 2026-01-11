#!/bin/bash
git checkout 4dd2e6ec5b81becd32dc25d85d977510d363a419
./scripts/feeds update -a
./scripts/feeds install -a
unset CFLAGS
unset CXXFLAGS
cp netgear-wac124-openwrt-config .config
make -j$(getconf _NPROCESSORS_ONLN) V=sc defconfig download clean world && cd bin/targets/ramips/mt7621 && ls
