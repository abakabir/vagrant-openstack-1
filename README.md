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

- Setup SSH access

```
systemctl start sshd
```

1. Install Vagrant: https://www.vagrantup.com/

2. Install vagrant-libvirt plugin: https://github.com/vagrant-libvirt/vagrant-libvirt#installation

```
vagrant plugin install vagrant-libvirt
```

3. Install qemu and libvirt on your hypervisor/desktop: https://github.com/vagrant-libvirt/vagrant-libvirt#installation

4. Clone repository

```
git clone git@github.com:homeski/vagrant-openstack.git
```

5. Download vagrant image

```
vagrant box add homeski/rhel7.3-osp
```

6. Bring up boxes

```
./vagrant-up.sh
```

7. Destroy the libvirt domains and detach the Vagrant NIC

```
for node in ctl1 cpt1 cpt2; do
virsh destroy vagrant-openstack_${node}
virsh detach-interface vagrant-openstack_${node} network --persistent --mac `virsh dumpxml vagrant-openstack_${node} | grep -B4 vagrant-libvirt | grep mac | cut -d "'" -f2`
done
```

8. Grab the MAC addresses of the provisioning NICs

```
for node in ctl1 ctl2 ctl3 cpt1 cpt2; do
  MAC=`virsh dumpxml vagrant-openstack_${node} | grep -B4 provisioning | grep mac | cut -d "'" -f2`
  echo vagrant-openstack_${node}=${MAC}
done
```

9. Libvirt VirtualPowerManager setup

```
cat << EOF > /etc/polkit-1/localauthority/50-local.d/50-libvirt-user-stack.pkla
[libvirt Management Access]
Identity=unix-user:`whoami`
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF
```

### Undercloud installation

1. Add the initial user, subscribe the system, update and reboot

```
useradd stack
echo pass | passwd stack --stdin

echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack

su - stack

# Register system

sudo subscription-manager register --username=`echo foo` --password=`echo bar`
sudo subscription-manager attach --pool=`cat ./pool-id`

sudo subscription-manager repos --disable=*
sudo subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-rh-common-rpms --enable=rhel-ha-for-rhel-7-server-rpms --enable=rhel-7-server-openstack-11-rpms

sudo yum install git vim tmux tree -y
sudo yum update -y
sudo reboot now
```

2. Setup the Undercloud 

```
vagrant ssh dir

sudo su - stack

sudo yum install python-tripleoclient -y

mkdir ~/images
cp -r /templates /home/stack/templates
cp /templates/undercloud/undercloud.conf /home/stack/

time openstack undercloud install

sudo systemctl list-units openstack-*

source ~/stackrc

sudo yum install rhosp-director-images rhosp-director-images-ipa -y

cd ~/images
for i in /usr/share/rhosp-director-images/overcloud-full-latest-11.0.tar /usr/share/rhosp-director-images/ironic-python-agent-latest-11.0.tar; do
  tar -xvf $i;
done

openstack overcloud image upload --image-path /home/stack/images/

openstack image list
ls -l /httpboot

openstack subnet set --dns-nameserver 192.168.121.1 --dns-nameserver 8.8.8.8 `openstack subnet list | grep ctlplane | awk '{print $2}'`
```

3. Copy the SSH key to the hypervisor so that IPMI works

```
ssh-copy-id -i ~/.ssh/id_rsa.pub homeski@192.168.122.1
```

### Overcloud deployment

1. Deploy the overcloud 

```
# Add MAC addresses to instackenv
vi /home/stack/instackenv.json

# Import "baremetal"

openstack overcloud node import ~/instackenv.json
openstack baremetal node list

# Comment out eth0 on KVM domain on host

openstack overcloud node introspect --all-manageable --provide

openstack overcloud profiles list

cd /home/stack

./templates/scripts/deploy-overcloud-multiple-nics.sh
```