#!/bin/sh -eux

nix-env -iA nixos.git

git clone https://github.com/Iagilev/nixos-config-libvirt.git /mnt/.setup

cd /mnt/.setup && nixos-install --flake .#nixbox
