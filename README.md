# vagrant-openstack

## What

Virtualized OSP 11 deployment using Vagrant and libvirt.

## Bare metal used

- ATX Desktop tower
- i7-4790K
- 32GB DDR3
- Linux Mint 18.

## Tools

- ansible
- libvirt
- vagrant
- vagrant-libvirt

## Networks

### Controller

```
1. Provisioning / Control Plane
| 2. Storage
| | 3. Storage Management
| | | 4. Internal API
| | | | 5. Tenant
| | | | | 6. External
| | | | | |  
| | | | | | 1. 192.168.24.0/24
  | | | | | 2. 192.168.34.0/24
    | | | | 3. 192.168.44.0/24
      | | | 4. 192.168.54.0/24
        | | 5. 172.16.0.0/24
          | 6. 10.0.0.0/24
```

### Compute

```
1. Provisioning / Control Plane
| 2. Storage
| | 3. Internal API
| | | 4. Tenant  
| | | |
| | | | 1. 192.168.24.0/24
  | | | 2. 192.168.34.0/24
    | | 3. 192.168.54.0/24
      | 4. 172.16.0.0/24  
```

## How to use

### Hypervisor setup

1. Install Vagrant: https://www.vagrantup.com/

2. Install vagrant-libvirt plugin: https://github.com/vagrant-libvirt/vagrant-libvirt#installation

```
vagrant plugin install vagrant-libvirt
```

3. Install qemu and libvirt on your hypervisor/desktop. See https://github.com/vagrant-libvirt/vagrant-libvirt#installation for installation steps.

```
# Linux
## Follow steps at above link

# OSX 10.12.6 Sierra
brew install libvirt qeumu gcc libtool automake gettext
# for autopoint
export PATH=/usr/local/Cellar/gettext/0.19.8.1/bin:$PATH

git clone git://libvirt.org/libvirt.git && cd libvirt

# compile
./automake.sh --system
make
```
