# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "homeski/rhel7.3-osp"

  # https://github.com/vagrant-libvirt/vagrant-libvirt
  provider = "libvirt"

  config.ssh.private_key_path = "keys/vagrant_private_key"
  config.ssh.insert_key = false

  config.vm.synced_folder ".", "/vagrant", disabled: true

  # https://github.com/devopsgroup-io/vagrant-hostmanager
  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true

  # https://github.com/vagrant-landrush/landrush
  config.landrush.enabled = true
  # This should be the default..but set it just in case
  config.landrush.upstream "8.8.8.8"
  # Don't use default TLD of vagrant.test
  # This seems to cause issues with packets intermittently dropping for some reason?
  config.landrush.tld = 'example.com'

  config.vm.define "dir" do |n|
    n.vm.provider provider do |v|
      v.memory = 8192
      v.cpus = 4
    end

    n.vm.synced_folder "templates/", "/templates", type: 'rsync'

    n.vm.hostname = "dir.example.com"
    n.vm.network "private_network",
      libvirt__network_name: "provisioning",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      ip: "192.168.24.2"
    n.vm.network "private_network",
      libvirt__network_name: "external",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "nat",
      ip: "10.0.0.8"
  end

  config.vm.define "ctl1" do |n|
    n.vm.provider provider do |v|
      v.memory = 8912
      v.cpus = 4
    end

    n.vm.hostname = "ctl1.example.com"
    n.vm.network "private_network",
      libvirt__network_name: "provisioning",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.24.10"
    n.vm.network "private_network",
      libvirt__network_name: "storage",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.34.10"
    n.vm.network "private_network",
      libvirt__network_name: "storage-mgmt",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.44.10"
    n.vm.network "private_network",
      libvirt__network_name: "internal-api",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.54.10"
    n.vm.network "private_network",
      libvirt__network_name: "tenant",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "172.16.0.10"
    n.vm.network "private_network",
      libvirt__network_name: "external",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "nat",
      auto_config: false,
      ip: "10.0.0.10"
  end

  config.vm.define "ctl2" do |n|
    n.vm.provider provider do |v|
      v.memory = 8912
      v.cpus = 4
    end

    n.vm.hostname = "ctl2.example.com"
    n.vm.network "private_network",
      libvirt__network_name: "provisioning",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.24.11"
    n.vm.network "private_network",
      libvirt__network_name: "storage",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.34.11"
    n.vm.network "private_network",
      libvirt__network_name: "storage-mgmt",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.44.11"
    n.vm.network "private_network",
      libvirt__network_name: "internal-api",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.54.11"
    n.vm.network "private_network",
      libvirt__network_name: "tenant",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "172.16.0.11"
    n.vm.network "private_network",
      libvirt__network_name: "external",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "nat",
      auto_config: false,
      ip: "10.0.0.11"
  end

  config.vm.define "ctl3" do |n|
    n.vm.provider provider do |v|
      v.memory = 8912
      v.cpus = 4
    end

    n.vm.hostname = "ctl3.example.com"
    n.vm.network "private_network",
      libvirt__network_name: "provisioning",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.24.12"
    n.vm.network "private_network",
      libvirt__network_name: "storage",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.34.12"
    n.vm.network "private_network",
      libvirt__network_name: "storage-mgmt",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.44.12"
    n.vm.network "private_network",
      libvirt__network_name: "internal-api",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.54.12"
    n.vm.network "private_network",
      libvirt__network_name: "tenant",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "172.16.0.12"
    n.vm.network "private_network",
      libvirt__network_name: "external",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "nat",
      auto_config: false,
      ip: "10.0.0.12"
  end

  config.vm.define "cpt1" do |n|
    n.vm.provider provider do |v|
      v.memory = 4096
      v.cpus = 4
      v.cpu_mode = "host-passthrough"
    end

    n.vm.hostname = "cpt1.example.com"
    n.vm.network "private_network",
      libvirt__network_name: "provisioning",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.24.20"
    n.vm.network "private_network",
      libvirt__network_name: "storage",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.34.20"
    n.vm.network "private_network",
      libvirt__network_name: "internal-api",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "192.168.54.20"
    n.vm.network "private_network",
      libvirt__network_name: "tenant",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false,
      ip: "172.16.0.10"
  end
end
