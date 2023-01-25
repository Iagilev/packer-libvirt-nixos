#!/bin/sh -eux

DEBUG="${DEBUG:-false}"
VERSION="${VERSION:-22.11}"

echo "Start install ..."

packer_http="http://${PACKER_HTTP_ADDR}"
nixos-generate-config --root /mnt

if [ "$GRUB" == "true" ]; then
    boot_loader="boot-loader-grub.nix"
else
    boot_loader="boot-loader-systemd-boot.nix"
fi

curl -sf "$packer_http/vagrant.nix" > /mnt/etc/nixos/vagrant.nix
curl -sf "$packer_http/vagrant-hostname.nix" > /mnt/etc/nixos/vagrant-hostname.nix
curl -sf "$packer_http/vagrant-network.nix" > /mnt/etc/nixos/vagrant-network.nix
curl -sf "$packer_http/hardware-configuration.nix" > /mnt/etc/nixos/hardware-builder.nix
curl -sf "$packer_http/configuration.nix" > /mnt/etc/nixos/configuration.nix
curl -sf "$packer_http/custom-configuration.nix" > /mnt/etc/nixos/custom-configuration.nix
curl -sf "$packer_http/${boot_loader}" > /mnt/etc/nixos/boot-loader.nix
sed -i "s/system.stateVersion =.*/system.stateVersion = \"${VERSION}\";/g" /mnt/etc/nixos/configuration.nix

if [ "$DEBUG" == "true" ]; then
    ls -la /mnt
    ls -la /mnt/etc/nixos
    sleep infinity
fi

nixos-install
