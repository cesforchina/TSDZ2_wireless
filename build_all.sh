# 一键编译固件并生成 bootloader settings
# set -e

#!/bin/bash
# 一键编译固件并生成 bootloader settings
set -e

# 0. 编译 bootloader

# 1. 编译固件
echo "[1/3] 编译固件..."
docker run --rm -it -v "$(pwd)":/workspace nrf5-sdk-env bash -c 'cd /workspace/EBike_wireless_remote/firmware && make clean && make -j'


# 2. 生成 bootloader settings
echo "[2/3] 生成 bootloader settings..."
docker run --rm -v "$(pwd)":/work nrfutil:2.7 settings generate \
  --family NRF52840 \
  --application /work/EBike_wireless_remote/firmware/_build/TSDZ2_wireless_remote.hex \
  --application-version-string 0.7.0 \
  --bootloader-version 10 \
  --bl-settings-version 2 \
  /work/EBike_wireless_remote/firmware/_build/bl_settings.hex

# 3. 合并 hex

# 4. 生成 OTA 包
echo "[4/4] 生成 OTA 包..."
docker run --rm -v "$(pwd)":/work nrfutil:2.7 pkg generate \
  --hw-version 52 \
  --sd-req 0xB9 \
  --application-version-string 0.7.0 \
  --application /work/EBike_wireless_remote/firmware/_build/TSDZ2_wireless_remote.hex \
  --key-file /work/EBike_wireless_remote/firmware/include/private.key \
  --app-boot-validation VALIDATE_ECDSA_P256_SHA256 \
  /work/EBike_wireless_remote/firmware/_build/TSDZ2_wireless_remote_ota_update.zip

echo "全部完成！"

echo "[2/2] 生成 DFU 包..."
docker run --rm -v "$(pwd)":/work nrfutil:2.7 pkg generate \
  --hw-version 52 \
  --sd-req 0xB9 \
  --application-version-string 0.7.0 \
  --application /work/EBike_wireless_remote/firmware/_build/TSDZ2_wireless_remote.hex \
  --key-file /work/EBike_wireless_remote/firmware/include/private.key \
  --app-boot-validation VALIDATE_ECDSA_P256_SHA256 \
  /work/EBike_wireless_remote/firmware/_build/TSDZ2_wireless_remote_ota_update.zip
