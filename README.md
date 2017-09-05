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
| 1. Provisioning / Control Plane
| | 2. Storage
| | | 3. Storage Management
| | | |4. Internal API
| | | | |5. Tenant
| | | | | | 6. External  

| | | | | | 1. 192.168.24.0/24
  | | | | | 2. 192.168.34.0/24
    | | | | 3. 192.168.44.0/24
      | | | 4. 192.168.54.0/24
        | | 5. 172.16.0.0/24
          | 6. 10.0.0.0/24
```

### Compute

```
| 1. Provisioning / Control Plane
| | 2. Storage
| | | 3. Internal API
| | | | 4. Tenant  
| | | |
| | | | 1. 192.168.24.0/24
  | | | 2. 192.168.34.0/24
    | | 3. 192.168.54.0/24
      | 4. 172.16.0.0/24  
```
