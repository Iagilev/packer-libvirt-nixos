#!/bin/sh -eux

DEBUG="${DEBUG:-false}"

echo "Start parted ..."

parted --script /dev/vda -- mklabel gpt
parted --script /dev/vda -- mkpart ESP fat32 1MiB 512MiB
parted --script /dev/vda -- set 1 esp on
parted --script /dev/vda -- mkpart primary 512MiB 100%
partprobe

if [ "$DEBUG" == "true" ]; then
    fdisk -l
fi

pvcreate /dev/vda2
vgcreate vg /dev/vda2
lvcreate -l '100%FREE' -n nixos vg

if [ "$DEBUG" == "true" ]; then
    lsblk
fi

mkfs.fat -F 32 -n boot /dev/vda1
mkfs.ext4 -L nixos /dev/vg/nixos

mount /dev/vg/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

if [ "$DEBUG" == "true" ]; then
    df -h
fi

if [ "$DEBUG" == "true" ]; then
    ls -la /mnt
fi
