# meta-rcar-demo
Demo correction for R-Car

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

