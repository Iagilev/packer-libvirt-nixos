ifneq (,$(wildcard ./.env))
    include .env
    export
endif

version:
	@echo "Build for x86_64-linux architecture and using the unstable NixOS iso version"

packer-init:
	packer init -upgrade nixos.pkr.hcl

build: version nixos.pkr.hcl
	packer build \
	-var arch=${ARCH} \
	-var builder="${BUILDER}" \
	-var version=${VERSION} \
	-var iso_checksum="$(shell curl -sL https://channels.nixos.org/nixos-${VERSION}/latest-nixos-minimal-${ARCH}-linux.iso.sha256 | grep -Eo '^[0-9a-z]{64}')" \
	-var headless="${HEADLESS}" \
	-var machine_type="${MACHINE_TYPE}" \
	-var efi_firmware_code="${EFI_FIRMWARE_CODE}" \
	-var efi_firmware_vars="${EFI_FIRMWARE_VARS}" \
	-var output_box="${OUTPUT_BOX}" \
	--only=${BUILDER} \
	nixos.pkr.hcl

vagrant-add:
	@test -f ${OUTPUT_BOX}/packer-nixos-unstable-${BUILDER}-${ARCH}.box && vagrant box add --force packer-nixos-${ARCH} ${OUTPUT_BOX}/packer-nixos-unstable-${BUILDER}-${ARCH}.box

vagrant-up:
	@vagrant up

vagrant-ssh:
	@vagrant ssh

vagrant-down:
	@vagrant destroy -f

box-remove:
	@rm -f ${OUTPUT_BOX}/packer-nixos-unstable-${BUILDER}-${ARCH}.box

vagrant-remove:
	@vagrant box remove packer-nixos-${ARCH}

virsh-vol-remove:
	@virsh vol-delete "$(shell virsh vol-list default --details | grep packer-nixos-${ARCH} | awk '{print $$1}')" --pool default

clean: vagrant-remove virsh-vol-remove box-remove

clean-log:
	@rm -f build.log
