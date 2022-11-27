#!/bin/sh -eux

DEBUG="${DEBUG:-false}"

echo "Start install ..."

packer_http="http://${PACKER_HTTP_ADDR}"
nixos-generate-config --root /mnt

curl -sf "$packer_http/vagrant.nix" > /mnt/etc/nixos/vagrant.nix
curl -sf "$packer_http/vagrant-hostname.nix" > /mnt/etc/nixos/vagrant-hostname.nix
curl -sf "$packer_http/vagrant-network.nix" > /mnt/etc/nixos/vagrant-network.nix
curl -sf "$packer_http/hardware-configuration.nix" > /mnt/etc/nixos/hardware-builder.nix
curl -sf "$packer_http/configuration.nix" > /mnt/etc/nixos/configuration.nix
curl -sf "$packer_http/custom-configuration.nix" > /mnt/etc/nixos/custom-configuration.nix

if [ "$DEBUG" == "true" ]; then
    ls -la /mnt
    ls -la /mnt/etc/nixos
    # sleep infinity
fi

nixos-install
