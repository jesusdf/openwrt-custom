# OpenWRT firmware for Netgear WAC124 with badblocks

There are some issues with this router if the memory reports badblocks. The mtd partition table is defined in upstream as fixed offsets. When there are badblocks present, the base addresses get shifted, and the device cannot boot, or boots but reports misleading hardware information.

Two years ago, [I reported that behaviour on the OpenWRT forums](https://forum.openwrt.org/t/strange-behaviour-on-5g-wifi-with-netgear-wac124/74771) and got a hint that [there was a patch to dynamically configure the mtd partition table](http://lists.infradead.org/pipermail/openwrt-devel/2020-June/029857.html ). That patch fixed my issues.

Recently, I tried to update the firmware to the latest version. Despite of using the prebuilt binaries or my own ones, the router was stuck in a boot loop (it didn't start the fast blinking led sequence, so the kernel was not properly booted).

I did some troubleshooting building a smaller kernel with just the bare minimum but it failed too.

[I updated that old patch to work with the latest version of OpenWRT](https://github.com/jesusdf/openwrt-custom/blob/main/netgear-partition-badblocks.patch), and it booted fine.

I tought that the badblocks patch was already in upstream, but it seems that it's not. The mtd is still defined as fixed offsets.

This patch also works with my Netgear R6260 (that it also happens to have badblocks), which is almost the same router, with just a different target in the build configuration. It should work fine with other routers from the same family/era, as the Netgear R7000 (untested).

For reference, these are the fixed partitions defined in upstream:

```
[    1.011099] Scanning device for bad blocks
[    1.517170] Bad eraseblock 393 at 0x000003120000
[    2.323428] 7 fixed-partitions partitions found on MTD device mt7621-nand
[    2.336949] Creating 7 MTD partitions on "mt7621-nand":
[    2.347360] 0x000000000000-0x000000100000 : "u-boot"
[    2.358704] 0x000000100000-0x000000200000 : "SC PART_MAP"
[    2.370774] 0x000000200000-0x000000600000 : "kernel"
[    2.382122] 0x000000600000-0x000002e00000 : "ubi"
[    2.392997] 0x000002e00000-0x000004600000 : "reserved0"
[    2.404913] 0x000004600000-0x000004800000 : "factory"
[    2.416306] 0x000004800000-0x000008000000 : "reserved1"
```

And these are the dynamic partitions detected by the patch:

```
[    0.987317] Scanning device for bad blocks
[    1.031536] Bad eraseblock 28 at 0x000000380000
[    1.153831] Bad eraseblock 118 at 0x000000ec0000
[    2.354578] scpart: valid 'SC PART MAP' found (29 partitions)
[    2.366187] 29 scpart partitions found on MTD device mt7621-nand
[    2.378145] Creating 29 MTD partitions on "mt7621-nand":
[    2.388727] 0x000000000000-0x000000100000 : "u-boot"
[    2.399980] 0x000000100000-0x000000200000 : "SC PART_MAP"
[    2.412007] 0x000000200000-0x000000620000 : "kernel"
[    2.423169] 0x000000620000-0x000002e40000 : "ubi"
[    2.434038] 0x000002e40000-0x000003040000 : "English UI"
[    2.445932] 0x000003040000-0x000003240000 : "ML1"
[    2.456600] 0x000003240000-0x000003440000 : "ML2"
[    2.467248] 0x000003440000-0x000003640000 : "ML3"
[    2.477874] 0x000003640000-0x000003840000 : "ML4"
[    2.488398] 0x000003840000-0x000003a40000 : "ML5"
[    2.499014] 0x000003a40000-0x000003c40000 : "ML6"
[    2.509511] 0x000003c40000-0x000003e40000 : "ML7"
[    2.520021] 0x000003e40000-0x000004040000 : "ML8"
[    2.530635] 0x000004040000-0x000004240000 : "ML9"
[    2.541143] 0x000004240000-0x000004440000 : "ML10"
[    2.551795] 0x000004440000-0x000004640000 : "ML11"
[    2.562519] 0x000004640000-0x000004840000 : "factory"
[    2.573755] 0x000004840000-0x000004a40000 : "SC Private Data"
[    2.586378] 0x000004a40000-0x000004c40000 : "POT"
[    2.596891] 0x000004c40000-0x000004e40000 : "Traffic Meter"
[    2.609173] 0x000004e40000-0x000005040000 : "SC PID"
[    2.620198] 0x000005040000-0x000005240000 : "SC Nvram"
[    2.631578] 0x000005240000-0x000005440000 : "Ralink Nvram"
[    2.643676] 0x000005440000-0x000005640000 : "reserved0"
[    2.655215] 0x000005640000-0x000005840000 : "reserved1"
[    2.666820] 0x000005840000-0x000005a40000 : "reserved2"
[    2.678492] 0x000005a40000-0x000005c40000 : "reserved3"
[    2.690036] 0x000005c40000-0x000005e40000 : "reserved4"
[    2.701590] 0x000005e40000-0x000007f80000 : "reserved5"
```

Install build dependencies
----
```
sudo apt update
sudo apt install build-essential gawk gcc-multilib flex git gettext libncurses5-dev libssl-dev python3-distutils rsync unzip zlib1g-dev clang
```

Download and update the sources
----
```
git clone https://github.com/jesusdf/openwrt-custom.git
cd openwrt-custom
git clone https://git.openwrt.org/openwrt/openwrt.git
cp netgear* openwrt/
rm openwrt/target/linux/generic/backport-*/411-*-mtd-parsers-add-support-for-Sercomm-partitions.patch
rm openwrt/target/linux/generic/pending-*/435-mtd-add-routerbootpart-parser-config.patch
cd openwrt
# Latest commit when this repository was built: https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=f4ca4187cde01a3e412f10657bec0790d3a4cd94
git checkout f4ca4187cde01a3e412f10657bec0790d3a4cd94
```

Update the feeds
----
```
./scripts/feeds update -a
./scripts/feeds install -a
```

Apply the partition patch
----
```
cat netgear-partition-badblocks.patch | patch -p1
```

Configure the firmware image and the kernel
----

Run the following commands as a normal user, never as root:
```
make -j12 menuconfig
# Exit without saving
# For Netgear WAC124
cp netgear-wac124-openwrt-config .config
# For Netgear R6260
cp netgear-r6260-openwrt-config .config
make -j12 menuconfig
```

Ensure that the custom packages are selected (like ntpclient on Network\Time Synchronization) and continue with the kernel compilation:

```
make -j12 kernel_menuconfig
cp netgear-kernel-config build_dir/target-mipsel_24kc_musl/linux-ramips_mt7621/linux-5.10.143/.config
make -j12 kernel_menuconfig
```

Ensure that the following options in the kernel configuration, and save it:
```
<*> General setup\Kernel .config support
[*] General setup\Enable access to .config through /proc/config.gz
<*> Device Drivers\Memory Technology Device (MTD) support -->\Partition parsers\Sercomm partition table parser
```

Build the firmware image
----

```
make -j12 defconfig download clean world
```

If it fails, add the following parameter to have a verbose output: V=sc
