packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

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

variable "efi_firmware_code" {
  type    = string
  default = "/usr/share/edk2-ovmf/x64/OVMF_CODE.fd"
}

variable "efi_firmware_vars" {
  type    = string
  default = "/usr/share/edk2-ovmf/x64/OVMF_VARS.fd"
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

variable "output_box" {
  type    = string
  default = "box"
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
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  cdrom_interface  = "ide"
  format           = "qcow2"
  http_directory   = null
  iso_checksum     = var.iso_checksum
  iso_url          = local.iso_url
  machine_type     = var.machine_type
  shutdown_command = "echo '${var.password}'|sudo -S shutdown -P now"
  ssh_password     = var.password
  ssh_username     = "root"
  ssh_timeout      = "50m"
  headless         = var.headless
  memory           = var.memory
  cpu_model      = "host"
  qemuargs          = [
    ["-vga","virtio"], # if vga is not virtio, output is garbled for some reason
    ["-boot", "menu=on"],
  ]
  vtpm              = true
  use_pflash        = true
  efi_firmware_code = var.efi_firmware_code
  efi_firmware_vars = var.efi_firmware_vars
}


build {
  sources = ["source.qemu.nixos-x86_64-uefi"]

  provisioner "shell" {
      scripts = fileset(".", "scripts/{00-parted,01-install,99-postinstall}.sh")
  }

  post-processor "vagrant" {
    provider_override    = "libvirt"
    vagrantfile_template = "./Vagrantfile-uefi.template"
    output               = "${var.output_box}/packer-nixos-unstable-${var.builder}-${var.arch}.box"
  }
}
