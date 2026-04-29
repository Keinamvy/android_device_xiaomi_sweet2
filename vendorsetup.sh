#!/bin/bash

# Apply vold sdcardfs fallback patch
cd system/vold
curl -sL "https://raw.githubusercontent.com/MisterZtr/LineageOS_gsi/refs/heads/lineage-23.2/patches/trebledroid-staging/platform_system_vold/0001-vold-use-sdcardfs-as-fallback-when-FUSE-BPF-is-unavai.patch" | patch -p1 -N -r -
cd - > /dev/null
