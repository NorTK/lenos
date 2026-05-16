#!/bin/bash

set -ex

echo "Creating Test Disk"
#sudo rm -rf root-disk
sudo make prepare-disk
pushd root-disk
sudo mkdir -p boot/efi/boot
sudo cp -rp boot/grub2 boot/efi/boot/.
sudo cp usr/lib/grub/x86_64-efi/raid6rec.mod boot/efi/boot/grub2/x86_64-efi/.
popd
sudo make create-disk

echo "Testing shit"
make test-disk
