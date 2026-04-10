#!/bin/bash
# Apply vold sdcardfs fallback patch
cd system/vold
curl -sL "https://raw.githubusercontent.com/MisterZtr/LineageOS_gsi/refs/heads/lineage-23.2/patches/trebledroid-staging/platform_system_vold/0001-vold-use-sdcardfs-as-fallback-when-FUSE-BPF-is-unavai.patch" | patch -p1 -N -r -
cd - > /dev/null

PATCH_DIR="device/xiaomi/sweet2/patches"

# Flags explained:
# -p1: Strip path
# -N: Ignore patches that are already applied (prevents double-patching/errors)
# -F 3: Fuzz factor for shifting line numbers
# -r -: Explicitly tell patch not to create .rej files (where supported)
# --no-backup-if-mismatch: Prevents .orig files
PATCH_FLAGS="-p1 -N -F 30 --no-backup-if-mismatch"

# Targeted directories for cleanup
TARGETS=("build/soong" "frameworks/base" "packages/apps/InfinitySuite" "vendor/extras")

if [ -d "$PATCH_DIR" ]; then
    echo "Applying patches from $PATCH_DIR..."
    
    # 1. Apply patches
    patch $PATCH_FLAGS -d build/soong < "$PATCH_DIR"/000*.patch
    patch $PATCH_FLAGS -d frameworks/base < "$PATCH_DIR"/001*.patch
    patch $PATCH_FLAGS -d packages/apps/InfinitySuite < "$PATCH_DIR"/002*.patch
    patch $PATCH_FLAGS -d vendor/extras < "$PATCH_DIR"/003*.patch

    # 2. Focused Cleanup (Only in touched directories to save time)
    echo "Cleaning up junk files in target directories..."
    for dir in "${TARGETS[@]}"; do
        if [ -d "$dir" ]; then
            find "$dir" -name "*.orig" -o -name "*.rej" -delete
        fi
    done
else
    echo "Patch directory not found: $PATCH_DIR"
    exit 1
fi

# 3. Dynamically remove the keybox array
XML_FILE="frameworks/base/core/res/res/values/infinity_config.xml"
if [ -f "$XML_FILE" ]; then
    # Check if the string exists before trying to delete (avoiding redundant writes)
    if grep -q "config_certifiedKeybox" "$XML_FILE"; then
        sed -i '/<string-array name="config_certifiedKeybox"/,/<\/string-array>/d' "$XML_FILE"
        echo "Keybox removed from $XML_FILE"
    else
        echo "Keybox already removed or not present in $XML_FILE. Skipping."
    fi
fi

echo "Done."
