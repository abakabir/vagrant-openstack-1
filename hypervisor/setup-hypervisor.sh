#!/bin/bash

# ----------------------------- #
# ----------------------------- #
# --- QEMU FS modifications --- #
# ----------------------------- #

virsh destroy vagrant-openstack_dir
virsh destroy vagrant-openstack_ctl1
virsh destroy vagrant-openstack_ctl2
virsh destroy vagrant-openstack_ctl3
virsh destroy vagrant-openstack_cpt1
virsh destroy vagrant-openstack_cpt2

sudo qemu-img resize /var/lib/libvirt/images/vagrant-openstack_dir.img +50G
sudo qemu-img resize /var/lib/libvirt/images/vagrant-openstack_ctl1.img +50G
sudo qemu-img resize /var/lib/libvirt/images/vagrant-openstack_ctl2.img +50G
sudo qemu-img resize /var/lib/libvirt/images/vagrant-openstack_ctl3.img +50G
sudo qemu-img resize /var/lib/libvirt/images/vagrant-openstack_cpt1.img +50G
sudo qemu-img resize /var/lib/libvirt/images/vagrant-openstack_cpt2.img +50G

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

# ----------------------------------- #
# --- Setup libvirt power manager --- #
# ----------------------------------- #

# On host KVM machine

cat << EOF > /etc/polkit-1/localauthority/50-local.d/50-libvirt-user-stack.pkla
[libvirt Management Access]
Identity=unix-user:homeski
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF

# Bring up overcloud nodes
./vagrant-up.sh

# Detach vagrant-libvirt NIC on all nodes
for node in ctl1 ctl2 ctl3 cpt1 cpt2; do
  virsh detach-interface vagrant-openstack_${node} network --persistent --mac `virsh dumpxml vagrant-openstack_${node} | grep -B4 vagrant-libvirt | grep mac | cut -d "'" -f2`
done

# Grab provisioning NIC MAC address for all nodes
for node in ctl1 ctl2 ctl3 cpt1 cpt2; do
  MAC=`virsh dumpxml vagrant-openstack_${node} | grep -B4 provisioning | grep mac | cut -d "'" -f2`
  echo vagrant-openstack_${node}=${MAC}
done
