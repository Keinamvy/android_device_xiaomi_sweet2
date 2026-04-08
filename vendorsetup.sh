#!/bin/bash
# Apply vold sdcardfs fallback patch
cd system/vold
curl -sL "https://raw.githubusercontent.com/MisterZtr/LineageOS_gsi/refs/heads/lineage-23.2/patches/trebledroid-staging/platform_system_vold/0001-vold-use-sdcardfs-as-fallback-when-FUSE-BPF-is-unavai.patch" | patch -p1 -N -r -
cd - > /dev/null

PATCH_DIR="device/xiaomi/sweet2/patches"
# Common flags to prevent .orig files and allow some "hunking" (fuzz)
PATCH_FLAGS="-p1 --no-backup-if-mismatch -F 3"

if [ -d "$PATCH_DIR" ]; then
    echo "Applying patches from $PATCH_DIR..."
    
    # Apply patches with backup suppression
    patch $PATCH_FLAGS -d build/soong < "$PATCH_DIR"/000*.patch
    patch $PATCH_FLAGS -d frameworks/base < "$PATCH_DIR"/001*.patch
    patch $PATCH_FLAGS -d packages/apps/InfinitySuite < "$PATCH_DIR"/002*.patch
    patch $PATCH_FLAGS -d vendor/extras < "$PATCH_DIR"/003*.patch
else
    echo "Patch directory not found: $PATCH_DIR"
    exit 1
fi

# Dynamically remove the keybox array
XML_FILE="frameworks/base/core/res/res/values/infinity_config.xml"
if [ -f "$XML_FILE" ]; then
    sed -i '/<string-array name="config_certifiedKeybox"/,/<\/string-array>/d' "$XML_FILE"
    echo "Keybox removed from $XML_FILE"
fi
