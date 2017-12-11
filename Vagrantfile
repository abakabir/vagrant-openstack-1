# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "homeski/rhel7.3-osp"

  # https://github.com/vagrant-libvirt/vagrant-libvirt
  provider = "libvirt"

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
      v.memory = 12288
      v.cpus = 4
    end

    n.vm.synced_folder ".", "/vagrant", type: 'rsync'

    n.vm.hostname = "dir.example.com"
    n.vm.network "private_network",
      libvirt__network_name: "provisioning",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
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
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "storage",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "storage-mgmt",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "internal-api",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "tenant",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "external",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "nat",
      auto_config: false,
      ip: "10.0.0.10"
    n.vm.network "private_network",
      libvirt__network_name: "baremetal",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "route",
      auto_config: false,
      ip: "192.168.64.0"
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
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "storage",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "storage-mgmt",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "internal-api",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "tenant",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "external",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "nat",
      auto_config: false,
      ip: "10.0.0.11"
    n.vm.network "private_network",
      libvirt__network_name: "baremetal",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "route",
      auto_config: false,
      ip: "192.168.64.0"
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
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "storage",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "storage-mgmt",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "internal-api",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "tenant",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "external",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "nat",
      auto_config: false,
      ip: "10.0.0.12"
    n.vm.network "private_network",
      libvirt__network_name: "baremetal",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "route",
      auto_config: false,
      ip: "192.168.64.0"
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
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "storage",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "internal-api",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "tenant",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
  end

  config.vm.define "cpt2" do |n|
    n.vm.provider provider do |v|
      v.memory = 4096
      v.cpus = 4
      v.cpu_mode = "host-passthrough"
      v.numa_nodes = [
        {:cpus => "0-1", :memory => "2048"},
        {:cpus => "2-3", :memory => "2048"}
      ]
    end

    n.vm.hostname = "cpt2.example.com"
    n.vm.network "private_network",
      libvirt__network_name: "provisioning",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "storage",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "internal-api",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "tenant",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "veryisolated",
      auto_config: false
  end

  config.vm.define "node0" do |n|
    n.vm.provider provider do |v|
      v.memory = 1024
      v.cpus = 1
      v.cpu_mode = "host-passthrough"
    end

    n.vm.hostname = "node0.example.com"
    n.vm.network "private_network",
      libvirt__network_name: "baremetal",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "route",
      auto_config: false,
      ip: "192.168.64.0"
  end
  config.vm.define "node1" do |n|
    n.vm.provider provider do |v|
      v.memory = 1024
      v.cpus = 1
      v.cpu_mode = "host-passthrough"
    end

    n.vm.hostname = "node1.example.com"
    n.vm.network "private_network",
      libvirt__network_name: "baremetal",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "route",
      auto_config: false,
      ip: "192.168.64.0"
  end
end
