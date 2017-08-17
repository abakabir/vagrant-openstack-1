# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "homeski/rhel7.3"

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
      v.memory = 16384
      v.cpus = 4
    end

    n.vm.hostname = "dir.example.com"
    n.vm.network "private_network",
      libvirt__network_name: "provisioning",
      libvirt__dhcp_enabled: false,
      ip: "192.168.26.254",
      libvirt__forward_mode: "none"
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
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "external",
      ip: "192.168.125.10"
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
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "external",
      ip: "192.168.125.11"
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
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "external",
      ip: "192.168.125.12"
  end

  config.vm.define "cpt1" do |n|
    n.vm.provider provider do |v|
      v.memory = 8192
      v.cpus = 4
      v.cpu_mode = "host-passthrough"
    end

    n.vm.hostname = "cpt1.example.com"
    n.vm.network "private_network",
      libvirt__network_name: "provisioning",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "external",
      ip: "192.168.125.13"
  end

  config.vm.define "cpt2" do |n|
    n.vm.provider provider do |v|
      v.cpus = 4
      v.cpu_mode = "host-passthrough"
      v.numa_nodes = [
        {:id => 0, :cpus => "0-1", :memory => "2048"},
        {:id => 1, :cpus => "2-3", :memory => "2048"},
      ]
    end

    n.vm.hostname = "cpt2.example.com"
    n.vm.network "private_network",
      libvirt__network_name: "provisioning",
      libvirt__dhcp_enabled: false,
      libvirt__forward_mode: "none",
      auto_config: false
    n.vm.network "private_network",
      libvirt__network_name: "external",
      ip: "192.168.125.14"
  end
end
