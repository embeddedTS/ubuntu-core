# Ubuntu Core for TS I.MX6 based systems


First install the build dependencies:
```
sudo apt-get install u-boot-tools snapcraft crossbuild-essential-armhf lzop snapd ubuntu-image
```

First register a key with snap [as shown here.](https://docs.ubuntu.com/core/en/guides/build-device/board-enablement#the-model-assertion)


Create a file in the root of this repository called "config.inc".  Add your authority id, and optionally a separate brand id.  This can be found on [your ubuntu account here](https://myapps.developer.ubuntu.com/dev/account/)

This file should contain something like:

```
AUTH_ID="longstringofcharacters"
```

Finally, just run:

```
./build.sh
```

This will compile the kernel, gadget snap, and assemble the base ubuntu core image in output/

