# Xen hypervisor setup for Sparrow Hawk

This repository provides a Xen-based virtualization setup for the
[Sparrow Hawk](https://rcar-community.github.io/Sparrow-Hawk/index.html) board
(R-Car V4H, r8a779g3), built with OpenEmbedded/Yocto and
[moulin](https://github.com/xen-troops/moulin).

## Domains

* Dom0: Minimal Linux (initramfs) that manages the other domains
* DomD: Driver domain based on `core-image-weston` from
  [meta-sparrow-hawk](https://github.com/rcar-community/meta-sparrow-hawk).
  It owns the physical devices and optionally provides virtio backends.
* DomU (optional): Yocto-based guest Linux
* DomA (optional): Android Automotive OS (AAOS 15/16/17, xenvm-trout)

## Layers

* `meta-xen-dom0`: Dom0 image, FIT image (`fitImage`) and guest domain configurations
* `meta-xen-domd`: DomD specific recipes
* `meta-xen-domd-virtio`: virtio backend support on DomD (used for DomA/DomU)
* `meta-xen-domu`: DomU specific recipes
* `meta-xen-domx`: Xen hypervisor and tools shared by all domains

## Contribution

### Question/Issue report

Please use GitHub Issues.

https://github.com/yhamamachi/meta-sparrow-hawk-xen/issues

### Suggestion with code

Please use Pull request feature.

https://github.com/yhamamachi/meta-sparrow-hawk-xen/pulls

## Dependencies

The following sources are fetched automatically by moulin.
See `prod-devel-rcar4_new.yaml` for the exact revisions.

* poky
* meta-openembedded
* meta-virtualization
* meta-selinux
* meta-sparrow-hawk
* Android / Android kernel manifests (only when DomA is enabled)

# Build Instructions

## Required Environment

* Refer to https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html to prepare Build Host.

* Install [moulin](https://github.com/xen-troops/moulin) and ninja:

```bash
pip3 install --user git+https://github.com/xen-troops/moulin
sudo apt install ninja-build
```

* This also needs git user name and email defined:

```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

* Building DomA (Android) requires a host that fulfills the
  [AOSP build requirements](https://source.android.com/docs/setup/start/requirements).
  The `repo` command is downloaded automatically by `build.sh`.

## Build using build script

```bash
git clone https://github.com/yhamamachi/meta-sparrow-hawk-xen
cd meta-sparrow-hawk-xen
# Dom0 + DomD
./build.sh
# Dom0 + DomD + DomU with virtio
./build.sh --domu --virtio
# Dom0 + DomD + DomU + DomA (virtio is always enabled with DomA)
./build.sh --domu --doma
```

Build options can be confirmed by `-h` option:

```bash
./build.sh -h
```

| Option | Description |
| --- | --- |
| `-a`, `--doma` | Build DomA (Android). Virtio is enabled forcibly. |
| `-u`, `--domu` | Build DomU |
| `-v`, `--virtio` | Enable virtio backend on DomD |
| `-A`, `--android-version <15\|16\|17>` | AAOS version for DomA (default: 15) |

All build outputs are placed under `work/`. The following images are generated:

* `work/full.img.gz`: Full image for SD card / eMMC / NVMe / USB storage
* `work/android_only.img.gz`: Android only image (only when DomA is enabled)

### Build in background

`scripts/backgroud-build-helper.sh` runs `build.sh` in background and keeps
its log under `work/.build-helper/`.

```bash
./scripts/backgroud-build-helper.sh start --domu --virtio
./scripts/backgroud-build-helper.sh status
./scripts/backgroud-build-helper.sh tail 50
./scripts/backgroud-build-helper.sh wait
./scripts/backgroud-build-helper.sh stop
```

# Boot Instructions

## Write image

Write `full.img.gz` to a microSD card:

```bash
gzip -cd work/full.img.gz | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
```

## Boot

The U-Boot environment provides the following boot commands. Run one of them
on the U-Boot console according to the boot device:

```
# microSD card
run xen_mmc
# USB storage
run xen_usb
# NVMe SSD
run xen_nvme
```

If they are not defined in your U-Boot environment, define them as follows:

```
setenv xen_mmc 'env delete bootargs; load mmc 0:1 ${loadaddr} fitImage && setenv conf_append "#boot_dev=mmcblk0" && source ${loadaddr}:script'
setenv xen_usb 'pci e && usb start && env delete bootargs; load usb 0:1 ${loadaddr} fitImage && setenv conf_append "#boot_dev=sda" && source ${loadaddr}:script'
setenv xen_nvme 'pci e && nvme scan; env delete bootargs; load nvme 0:1 ${loadaddr} fitImage && setenv conf_append "#boot_dev=nvme0n1" && source ${loadaddr}:script'
saveenv
```

These commands run the boot script contained in `fitImage`. It detects the
connected cameras, display and fan, and then boots Xen with the corresponding
configurations and `conf_append`.

## Boot configuration

Configurations are passed to Dom0 as `#<config>` strings. They are exposed to
Dom0 via `/proc/device-tree/chosen/u-boot,bootconf` and applied by
`dom*-set-root` scripts before starting guest domains.

| Config | Description |
| --- | --- |
| `boot_dev=<dev>` | Storage device which has the root filesystems of guest domains (default: `mmcblk0`). e.g. `nvme0n1`, `sda` |
| `j1-imx219`, `j1-imx462`, `j1-imx708` | Camera on J1 connector |
| `j2-imx219`, `j2-imx462`, `j2-imx708` | Camera on J2 connector |
| `rpi-display-2-7in`, `rpi-display-2-5in` | Raspberry Pi Touch Display 2 on J4 connector |
| `waveshare-panel` | Waveshare DSI panel on J4 connector |
| `fan-pwm`, `fan-argon40` | Fan |

Cameras and displays are detected automatically by the boot script and
applied to the DomD device tree as dt-overlays. The fan is not detected
automatically, so select its type by the `fan` variable (`pwm` or `argon40`):

```
setenv fan pwm
```

Other configurations can be added to `conf_append` in the boot commands above.

## USB/PCIe boot

NOTE: This is not officially supported yet, since the Yocto BSP does not
support it and the PCIe firmware is not distributed. It has been confirmed only
in a local environment.

1. Prepare U-Boot environment variables

```
setenv flash_pcie_fw_to_qspi_from_xen_mmc 'load mmc 0:2 ${loadaddr} lib/firmware/rcar_gen4_pcie.bin && sf probe; sf update ${loadaddr} 0x300000 ${filesize}'
setenv renesas_rcar_gen4_load_firmware 'run set_pcie_firmware_info && sf probe; sf read ${renesas_rcar_gen4_load_firmware_addr} 0x300000 ${renesas_rcar_gen4_load_firmware_size}'
setenv set_pcie_firmware_info 'setenv renesas_rcar_gen4_load_firmware_addr 0x54000000 && setenv renesas_rcar_gen4_load_firmware_size 0x8000'

setenv flash_nvme_xen 'pci e && nvme scan && tftp ${loadaddr} full.img.gz && gzwrite nvme 0 ${loadaddr} ${filesize} 400000 0'
setenv flash_usb_xen 'pci e && usb start && tftp ${loadaddr} full.img.gz && gzwrite usb 0 ${loadaddr} ${filesize} 100000 0'
```

2. Write PCIe firmware to QSPI flash (only once)

The following command reads the firmware from a microSD card which has the Xen
image, so insert it in advance. The firmware binary can also be written to QSPI
flash by any other method.

```
run flash_pcie_fw_to_qspi_from_xen_mmc
```

3. Write the image to the storage via TFTP (NVMe SSD case)

```
run flash_nvme_xen
```

4. Boot from the storage (NVMe SSD case)

```
run xen_nvme
```

For USB storage, use `flash_usb_xen` and `xen_usb` instead.

## Example: DomU + DomA multi display demo

Weston on DomD runs with `kiosk-shell` and assigns each domain to a display
(see `meta-xen-domd-virtio/recipes-graphics/wayland/weston-init.bbappend`):

| Output | Domain |
| --- | --- |
| `DP-1` (DisplayPort) | DomU |
| `DSI-1` (J4 connector) | DomA |

Connect both displays to show DomA and DomU at the same time.

1. Build

```bash
./build.sh --domu --doma
```

2. Boot (NVMe SSD case)

```
run xen_nvme
```

# Tips

## Enlarge DomA userdata partition

Change `TARGET_USERDATAIMAGE_PARTITION_SIZE` in
`work/android_<version>/device/epam/aosp-xenvm-trout/xenvm_trout_arm64/BoardConfig.mk`:

```
TARGET_USERDATAIMAGE_PARTITION_SIZE := 7516192768 # 7 GB
->
TARGET_USERDATAIMAGE_PARTITION_SIZE := 19327352832 # 18 GB
```

Then remove `boot.img` and rebuild:

```bash
rm work/android_<version>/out/target/product/xenvm_trout_arm64/boot.img
./build.sh <options>
```

# Reference

* R-Car Community site
  * https://rcar-community.github.io/
* Sparrow Hawk board page
  * https://rcar-community.github.io/Sparrow-Hawk/index.html
* meta-sparrow-hawk
  * https://github.com/rcar-community/meta-sparrow-hawk
* moulin
  * https://github.com/xen-troops/moulin
