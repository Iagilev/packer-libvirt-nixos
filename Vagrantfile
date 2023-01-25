# -*- mode: ruby -*-
# vi: set ft=ruby :

# check install plugins
REQUIRED_PLUGINS = %w(vagrant-libvirt)
exit unless REQUIRED_PLUGINS.all? do |plugin|
  Vagrant.has_plugin?(plugin) || (
    puts "The #{plugin} plugin is required. Please install it with:"
    puts "$ vagrant plugin install #{plugin}"
    false
  )
end

node_name = "nixos"

Vagrant.configure("2") do |config|
  config.vm.box = "packer-nixos-x86_64"
  config.nfs.verify_installed = false
  config.vm.define node_name do |node|
    node.vm.provider :libvirt do |libvirt|
      # A hypervisor name to access. Different drivers can be specified, but
      # this version of provider creates KVM machines only. Some examples of
      # drivers are KVM (QEMU hardware accelerated), QEMU (QEMU emulated),
      # Xen (Xen hypervisor), lxc (Linux Containers),
      # esx (VMware ESX), vmwarews (VMware Workstation) and more. Refer to
      # documentation for available drivers (http://libvirt.org/drivers.html).
      libvirt.cpu_mode = "host-passthrough"
      libvirt.driver = "kvm"
      libvirt.loader = "/run/libvirt/nix-ovmf/OVMF_CODE.fd"
      libvirt.machine_type = "q35"

      # The name of the server, where Libvirtd is running.
      libvirt.host = "localhost"

      # If use ssh tunnel to connect to Libvirt.
      # libvirt.connect_via_ssh = false

      # The username and password to access Libvirt. Password is not used when
      # connecting via ssh.
      # libvirt.username = "root"
      # libvirt.password = "secret"

      # Libvirt storage pool name, where box image and instance snapshots will
      # be stored.
      libvirt.storage_pool_name = "default"

      # Set a prefix for the machines that's different than the project dir name.
      #libvirt.default_prefix = ''
      #libvirt.cpus = 2
      #libvirt.numa_nodes = [{ :cpus => "0-1", :memory => 8192, :memAccess => "shared" }]
      #libvirt.memorybacking :access, :mode => "shared"
      libvirt.default_prefix = ""
      libvirt.cpus = 3
      libvirt.memory = 4096
      libvirt.uri = "qemu:///system"
      libvirt.sound_type = "ich9"
      libvirt.video_type = 'qxl'
      libvirt.channel :type => 'unix', :target_name => 'org.qemu.guest_agent.0', :target_type => 'virtio'
      libvirt.channel :type => 'spicevmc', :target_name => 'com.redhat.spice.0', :target_type => 'virtio'
      libvirt.video_vram = 16384
      libvirt.video_accel3d = false
      libvirt.graphics_gl = false
      libvirt.graphics_type = "spice"
    end
  end
  config.vm.synced_folder "./storage", "/vagrant", type: "nfs", nfs_version: 4, nfs_udp: false
end
