locals {
  iso_url = "https://channels.nixos.org/nixos-${var.version}/latest-nixos-minimal-${var.arch}-linux.iso"
}

variable "builder" {
  type        = string
  description = "builder"
}

variable "disk_size" {
  type    = string
  default = "50G"
}

variable "password" {
  type    = string
  default = "nixos"
}

variable "user" {
  type    = string
  default = "nixos"
}

variable "firmware" {
  type    = string
  default = "/usr/share/edk2-ovmf/x64/OVMF_CODE.fd"
}

variable "headless" {
  type    = bool
  default = true
}

variable "version" {
  type    = string
  default = "22.11"
}

variable "arch" {
  type    = string
  default = "x64_86"
}

variable "iso_checksum" {
  type    = string
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "boot_wait" {
  type    = string
  default = "45s"
}

variable "machine_type" {
  type    = string
  default = "q35"
}

source "qemu" "nixos-x86_64-uefi" {
  accelerator      = "kvm"
  boot_command     = [
    "sudo passwd<enter>",
    "${var.password}<enter>",
    "${var.password}<enter>"
    ]
  boot_wait        = var.boot_wait
  disk_compression = true
  disk_size        = var.disk_size
  format           = "qcow2"
  http_directory   = null
  iso_checksum     = var.iso_checksum
  iso_url          = local.iso_url
  machine_type     = var.machine_type
  #efi_firmware_code  = "/run/libvirt/nix-ovmf/OVMF_CODE.fd"
  #efi_firmware_vars  = "/run/libvirt/nix-ovmf/OVMF_VARS.fd"
  firmware         = var.firmware
  use_pflash       = true
  qemuargs         = [
    ["-cpu", "host"],
    ["-m", var.memory],
    ]
  shutdown_command = "echo '${var.password}'|sudo -S shutdown -P now"
  ssh_password     = var.password
  ssh_username     = "root"
  ssh_timeout      = "50m"
  headless         = var.headless
}


build {
  sources = ["source.qemu.nixos-x86_64-uefi"]

  provisioner "shell" {
      scripts = fileset(".", "scripts/{00-parted,01-install,99-postinstall}.sh")
  }

  post-processor "vagrant" {
    provider_override    = "libvirt"
    vagrantfile_template = "./Vagrantfile-uefi.template"
    output               = "packer-nixos-unstable-${var.builder}-${var.arch}.box"
  }
}
