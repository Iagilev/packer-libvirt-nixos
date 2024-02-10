#!/bin/sh -eux

nix-env -iA nixos.git

git clone https://github.com/Iagilev/nixos-config-libvirt.git /mnt/etc/nixos

nixos-install --flake /mnt/etc/nixos#nixbox
