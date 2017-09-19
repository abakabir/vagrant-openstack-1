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

1. Setup SSH access

```shell
systemctl start sshd
```

2. Install Vagrant: https://www.vagrantup.com/

3. Install vagrant-libvirt plugin: https://github.com/vagrant-libvirt/vagrant-libvirt#installation

```shell
vagrant plugin install vagrant-libvirt
```

4. Install qemu and libvirt on your hypervisor/desktop: https://github.com/vagrant-libvirt/vagrant-libvirt#installation

5. Clone repository

```shell
git clone git@github.com:homeski/vagrant-openstack.git
```

6. Download vagrant image

```shell
vagrant box add homeski/rhel7.3-osp
```

7. Bring up the director

```shell
vagrant up dir
```

8. Libvirt VirtualPowerManager setup

```shell
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

1. SSH into the Director, add the initial user, subscribe the system, update and reboot

```shell
vagrant ssh dir

sudo su -

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

SSH into the Director, and install the Undercloud


```shell
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

3. Copy the SSH key to the hypervisor so that virtual IPMI works

```shell
# Run this from the Director
ssh-copy-id -i ~/.ssh/id_rsa.pub <your_user>@192.168.122.1
```

### Overcloud deployment

1. On the Hypervisor, bring up all OSP nodes using Vagrant . **Note** Bring the machines up 1 at a time, otherwise vagrant-libvirt seems to crash

```shell
vagrant up ctl1 && \
  vagrant up ctl2 && \
  vagrant up ctl3 && \
  vagrant up cpt1 && \
  vagrant up cpt2 &&
```

2. In the `Vagrantfile`, we setup all the NICs that the controllers and computes need.

Vagrant does something special and adds in an extra NIC as eth0. It uses this NIC to SSH into each machine. Director introspection and deployment expects eth0 to be the provisioning NIC, which causes issues. Here we remove the NIC added by Vagrant so introspection will work.

```shell
# Detach vagrant-libvirt NIC on all nodes
for node in ctl1 ctl2 ctl3 cpt1 cpt2; do
  virsh detach-interface vagrant-openstack_${node} network --persistent --mac `virsh dumpxml vagrant-openstack_${node} | grep -B4 vagrant-libvirt | grep mac | cut -d "'" -f2`
done
```

3. Grab the MAC address of each provisioning NIC, to be used below

```shell
# Grab provisioning NIC MAC address for all nodes
for node in ctl1 ctl2 ctl3 cpt1 cpt2; do
  MAC=`virsh dumpxml vagrant-openstack_${node} | grep -B4 provisioning | grep mac | cut -d "'" -f2`
  echo vagrant-openstack_${node}=${MAC}
done
```

3. SSH into the Director and deploy the overcloud

```shell
vagrant ssh dir

sudo su - stack

source stackrc

# Add MAC addresses to instackenv
vi /home/stack/instackenv.json

# Import "baremetal"

openstack overcloud node import ~/instackenv.json
openstack baremetal node list

openstack overcloud node introspect --all-manageable --provide

openstack overcloud profiles list

cd /home/stack

./templates/scripts/deploy-overcloud-multiple-nics.sh
```
