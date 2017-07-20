#!/bin/bash -x

mkdir output > /dev/null 2>&1

source config.inc

if [ -z "$AUTH_ID" ]; then
	echo "You need to specify your AUTH_ID in config.inc"
	echo "Get this here: https://myapps.developer.ubuntu.com/dev/account/"
	exit 1
fi

if [ -z "$BRAND_ID" ]; then
	BRAND_ID="$AUTH_ID"
fi

cd snaps/tsimx6-kernel/
snapcraft clean kernel -s build
snapcraft --target-arch armhf
mv tsimx6-kernel_4.4.30_armhf.snap ../../output/tsimx6-kernel_4.4.30_armhf.snap
cd -

mkenvimage -r -s 8192  -o snaps/tsimx6-gadget/uboot.env snaps/tsimx6-gadget/uboot.env.in
mkimage -A arm -T script -C none -n 'TSIMX6 Ubuntu Core' -d snaps/tsimx6-gadget/boot-assets/boot/boot.scr snaps/tsimx6-gadget/boot-assets/boot/boot.ub

snapcraft --target-arch armhf snap snaps/tsimx6-gadget --output output/tsimx6-gadget_16.04-1_armhf.snap

cp models/tsimx6-model.json output/tsimx6-model.json
sed --in-place "s/YOURAUTHORITYIDHERE/${AUTH_ID}/" output/tsimx6-model.json
sed --in-place "s/YOURBRANDIDHERE/${BRAND_ID}/" output/tsimx6-model.json
TIMESTAMP=$(date --rfc-3339=seconds | sed 's/ /T/')
sed --in-place "s/TIMESTAMPHERE/${TIMESTAMP}/" output/tsimx6-model.json

cat output/tsimx6-model.json | snap sign -k default &> output/tsimx6.model
if [ ! -e output/tsimx6.model ]; then
	echo "Failed to sign model.  Make sure you have registered a \"default\" key with snap."
	echo "https://docs.ubuntu.com/core/en/guides/build-device/image-building"
fi

ubuntu-image \
	-c stable \
	--image-size 1G \
	--extra-snaps output/tsimx6-kernel_4.4.30_armhf.snap \
	--extra-snaps output/tsimx6-gadget_16.04-1_armhf.snap \
	-O output/ \
	output/tsimx6.model

mv output/tsimx6.img output/ubuntu-core-16-$(date +%F).img
