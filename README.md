# meta-rcar-demo
Demo correction for R-Car

# Boot

## U-Boot

```
env default -a && env delete bootargs && load mmc 0:1 ${loadaddr} fitImage && bootm ${loadaddr}
```

# Tips

## タッチパネルが動作しない

最新リビジョンでinput deviceとしてvirtio-tablet-pciが使われるようになったが、その設定ファイルがAndroid側にある。
古い環境を継続している場合、Android側が未更新でタッチ操作が効かないことがある。
以下は、Androidのデバイスファイル設定を更新して再度ビルドしなおすための手順。

```
git -C work_v4hsbc_xen/android/device/epam/aosp-xenvm-trout/ fetch github
git -C work_v4hsbc_xen/android/device/epam/aosp-xenvm-trout/ pull github android-15-xenvm-trout-ih-main
rm ./work_v4hsbc_xen/android/out/target/product/xenvm_trout_arm64/boot.img
./build.sh xxxxx
```

なお、旧来のidcファイルを別途adb pushで入れ込む方法を取れば別途インストールしなおす必要は無く、タッチパネルは動作するようになる。

## kernel startingでstackしてしまう。

以前はYocto用のU-Bootの使用で発生した問題だが、Xen側のATFを最新環境に変更することで解消された。
そのため、最新のXenをビルドすれば発生しない問題のはず。
もし、継続して問題が起きる場合は、下記の手順でU-Bootの更新がおすすめ。
```
setenv flash_loader_mmc 'load mmc 0:1 ${loadaddr} flash.bin && sf probe && sf update ${loadaddr} 0 ${filesize} && reset'
saveenv
run flash_loader_mmc
```

## USB/PCIe booting

現時点で、Yocto側での対応、FWの配布が行われていないため、内容は未保証。
ローカルでのブートでは問題ないことを確認済み。

1. U-Bootの環境変数の準備
```
setenv flash_pcie_fw_to_qspi_from_xen_mmc 'load mmc 0:2 ${loadaddr} lib/firmware/rcar_gen4_pcie.bin && sf probe; sf update ${loadaddr} 0x300000 ${filesize}'
setenv renesas_rcar_gen4_load_firmware 'run set_pcie_firmware_info && sf probe; sf read ${renesas_rcar_gen4_load_firmware_addr} 0x300000 ${renesas_rcar_gen4_load_firmware_size}'
setenv set_pcie_firmware_info 'setenv renesas_rcar_gen4_load_firmware_addr 0x54000000 && setenv renesas_rcar_gen4_load_firmware_size 0x8000'

setenv flash_nvme_xen 'pci e && nvme scan && tftp ${loadaddr} full.img.gz && gzwrite nvme 0 ${loadaddr} ${filesize} 400000 0'
setenv flash_usb_xen 'pci e && usb start && tftp ${loadaddr} full.img.gz && gzwrite usb 0 ${loadaddr} ${filesize} 100000 0'

setenv xen_nvme 'pci e && nvme scan && env delete bootargs && load nvme 0:1 ${loadaddr} fitImage && bootm ${loadaddr}#default#boot_dev=nvme0n1'
setenv xen_usb 'pci e && usb start && env delete bootargs && load usb 0:1 ${loadaddr} fitImage && bootm ${loadaddr}#default#boot_dev=sda'
```

2. (一度だけ実行で大丈夫なはず)QSPI flashへのPCIe firmwareの書き込み

下記コマンドで書き込む場合は事前にXenを書き込んだSDを接続しておくこと。
上級者の方は任意の手段でQSPIにFWバイナリを書き込んで頂いて大丈夫です。

```
run flash_pcie_fw_to_qspi_from_xen_mmc
```

3. NVMe SSDの例) Xenのバイナリをtftp経由で書き込む。

```
run flash_nvme_xen
```

4. NVMe SSDの例) NVMeからXenをブートする

```
run xen_nvme
```

## Android(DomA)のユーザーイメージ領域の拡大

android/device/epam/aosp-xenvm-trout/xenvm_trout_arm64/BoardConfig.mkの
TARGET_USERDATAIMAGE_PARTITION_SIZEを任意の値に変更する

```
Ex.)
TARGET_USERDATAIMAGE_PARTITION_SIZE := 7516192768 # 7 GB
↓
TARGET_USERDATAIMAGE_PARTITION_SIZE := 19327352832 # 18 GB
```

boot.imgを削除してAndroidを再ビルドする。
```
rm work_v4hsbc_xen/android/out/target/product/xenvm_trout_arm64/boot.img
```


## DomD dtbへのdt-overlayの有効化

bootmに対するconfigを使うことでdtbにdtboを当てた状態でDomDを起動することができる。
dt_overlayに対して、カンマ「,」区切りにdtboファイル名を指定する必要あり。
ToDo: U-Boot側での自動判別機能、Yocto BSPと同等の入力機能の追加。

例: j1-imx219 + j2-imx708
```
bootm ${loadaddr}#default#dt_overlay=r8a779g3-sparrow-hawk-camera-j1-imx219.dtbo,r8a779g3-sparrow-hawk-camera-j2-imx708.dtbo
```

