#!/bin/bash

# --- QEMU FS modifications

virsh destroy vagrant-openstack_dir
virsh destroy vagrant-openstack_ctl1
virsh destroy vagrant-openstack_cpt1

sudo qemu-img resize /var/lib/libvirt/images/vagrant-openstack_dir.img +50G
sudo qemu-img resize /var/lib/libvirt/images/vagrant-openstack_ctl1.img +50G
sudo qemu-img resize /var/lib/libvirt/images/vagrant-openstack_cpt1.img +50G

virsh start vagrant-openstack_dir

# Increase XFS on dir to 50GB

vagrant ssh dir

sudo su -

fdisk -l /dev/vda

(
echo d
echo n
echo p
echo 1
echo
echo
echo w
) | sudo fdisk /dev/vda

fdisk -l /dev/vda

partprobe
reboot now

vagrant ssh dir

sudo su -

xfs_growfs /dev/vda1 -d

# --- Install Undercloud

# Following documentation at:
# https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/11/html-single/director_installation_and_usage/

# Add stack user

useradd stack
passwd stack

echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack

su - stack

mkdir ~/images
cp -r /templates /home/stack/templates

# Register system

sudo subscription-manager register
sudo subscription-manager attach --pool=`cat ./pool-id`

sudo subscription-manager repos --disable=*
sudo subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-rh-common-rpms --enable=rhel-ha-for-rhel-7-server-rpms --enable=rhel-7-server-openstack-11-rpms

sudo yum install git vim tmux tree -y
sudo yum update -y
sudo reboot now

# Install Director packages

vagrant ssh dir

sudo su - stack

sudo yum install python-tripleoclient -y

cp /templates/undercloud/undercloud.conf /home/stack/

#  Deploy Undercloud

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

# --- Setup libvirt power manager

# On director

ssh-copy-id -i ~/.ssh/id_rsa.pub homeski@192.168.122.1 # -p23

# On host KVM machine

cat << EOF > /etc/polkit-1/localauthority/50-local.d/50-libvirt-user-stack.pkla
[libvirt Management Access]
Identity=unix-user:homeski
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF

# --- Setup Overcloud

jq . << EOF > ~/instackenv.json
{
  "ssh-user": "homeski",
  "ssh-key": "$(cat ~/.ssh/id_rsa)",
  "ssh-port": "23",
  "power_manager": "nova.virt.baremetal.virtual_power_driver.VirtualPowerManager",
  "host-ip": "192.168.122.1",
  "arch": "x86_64",
  "nodes": [
    {
      "pm_addr": "192.168.122.1",
      "pm_password": "$(cat ~/.ssh/id_rsa)",
      "pm_type": "pxe_ssh",
      "mac": [
        ""
      ],
      "cpu": "4",
      "memory": "4096",
      "disk": "60",
      "arch": "x86_64",
      "pm_user": "homeski",
      "name": "ctl1",
      "capabilities": "profile:control,boot_option:local"
    },
    {
      "pm_addr": "192.168.122.1",
      "pm_password": "$(cat ~/.ssh/id_rsa)",
      "pm_type": "pxe_ssh",
      "mac": [
        ""
      ],
      "cpu": "4",
      "memory": "4096",
      "disk": "60",
      "arch": "x86_64",
      "pm_user": "homeski",
      "name": "ctl2",
      "capabilities": "profile:control,boot_option:local"
    },
    {
      "pm_addr": "192.168.122.1",
      "pm_password": "$(cat ~/.ssh/id_rsa)",
      "pm_type": "pxe_ssh",
      "mac": [
        ""
      ],
      "cpu": "4",
      "memory": "4096",
      "disk": "60",
      "arch": "x86_64",
      "pm_user": "homeski",
      "name": "ctl3",
      "capabilities": "profile:control,boot_option:local"
    },
    {
      "pm_addr": "192.168.122.1",
      "pm_password": "$(cat ~/.ssh/id_rsa)",
      "pm_type": "pxe_ssh",
      "mac": [
        ""
      ],
      "cpu": "4",
      "memory": "4096",
      "disk": "60",
      "arch": "x86_64",
      "pm_user": "homeski",
      "name": "cpt1",
      "capabilities": "profile:compute,boot_option:local"
    }
  ]
}
EOF

# Import "baremetal"

openstack overcloud node import ~/instackenv.json
openstack baremetal node list

# Comment out eth0 on KVM domain on host

openstack overcloud node introspect --all-manageable --provide

openstack overcloud profiles list

# --- Deploy Overcloud

cd /home/stack

./templates/scripts/deploy-overcloud-multiple-nics.sh

# --- Boot first instance

openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano

openstack network create

openstack subnet create --network efb64350-550e-42cb-970f-be7ddaeaf497 --subnet-range 192.168.55.0/24 test-subnet

cd /home/stack/images
wget http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img

openstack image create "cirros" \
  --file cirros-0.3.5-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --public

openstack server create --flavor m1.nano --nic net-id=efb64350-550e-42cb-970f-be7ddaeaf497 --image cirros test1
