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

# -------------------------- #
# --- Install Undercloud --- #
# -------------------------- #

# Following documentation at:
# https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/11/html-single/director_installation_and_usage/

# Add stack user

useradd stack
passwd stack

echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack

su - stack

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

mkdir ~/images
cp -r /templates /home/stack/templates
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

# ----------------------------------- #
# --- Setup libvirt power manager --- #
# ----------------------------------- #

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

# Bring up overcloud nodes
./vagrant-up.sh

# Detach vagrant-libvirt NIC on all nodes
for node in ctl1 ctl2 ctl3 cpt1 cpt2; do
virsh detach-interface vagrant-openstack_${node} network --persistent --mac `virsh dumpxml vagrant-openstack_${node} | grep -B4 vagrant-libvirt | grep mac | cut -d "'" -f2`
done

# ------------------------ #
# --- Deploy Overcloud --- #
# ------------------------ #

# Grab provisioning NIC MAC address for all nodes
for node in ctl1 ctl2 ctl3 cpt1 cpt2; do
  MAC=`virsh dumpxml vagrant-openstack_${node} | grep -B4 provisioning | grep mac | cut -d "'" -f2`
  echo vagrant-openstack_${node}=${MAC}
done


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

# --------------------------- #
# --- Boot first instance --- #
# --------------------------- #

openstack flavor create --vcpus 1 --ram 512 --disk 1 m1.nano
openstack flavor create --vcpus 1 --ram 512 --disk 10 m1.micro

cd /home/stack/images
wget http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img
wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2

openstack image create "cirros" \
  --file cirros-0.3.5-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --public

openstack image create "centos7" \
  --file CentOS-7-x86_64-GenericCloud.qcow2 \
  --disk-format qcow2 --container-format bare \
  --public

# Test tenant networking
# openstack network create tenant
# openstack subnet create tenant --network tenant --dhcp --allocation-pool start=172.16.0.20,end=172.16.0.50 --gateway 172.16.0.1 --subnet-range 172.16.0.0/24 --dns-nameserver 8.8.8.8
# openstack server create --flavor m1.nano --nic net-id=`openstack network list | grep tenant | awk '{print $2}'` --image cirros test1
# openstack server create --flavor m1.nano --nic net-id=`openstack network list | grep tenant | awk '{print $2}'` --image cirros test2

# Test external networking using floating IPs
# openstack network create public --share --external --provider-network-type flat --provider-physical-network datacentre
# openstack subnet create public --network public --dhcp --allocation-pool start=10.0.0.20,end=10.0.0.50 --gateway 10.0.0.1 --subnet-range 10.0.0.0/24 --dns-nameserver 8.8.8.8
#
# openstack router create public
# openstack router set public --external-gateway public
# openstack router add subnet public tenant
# openstack floating ip create --port `os port list --server test1 -f value -c ID` public

os stack create -t /home/stack/templates/heat/test-stack.yaml --parameter image_name=cirros test-stack1

# Cleanup of external networking

# ----------------------- #
# --- Useful commands --- #
# ----------------------- #

# Monitor hypervisor info
watch 'free -h; echo ""; df -h; echo ""; virsh list; echo ""; ps aux  | awk '\''{print $6/1024 " MB\t\t" $11}'\''  | sort -n | tail'

# Show process MB usage
ps aux  | awk '{print $6/1024 " MB\t\t" $11}'  | sort -n

# Delete all baremetal servers
for i in `os baremetal node list | grep available | awk '{print $2}'`; do os baremetal node delete $i; done

# Show default services
cat /usr/share/openstack-tripleo-heat-templates/overcloud-resource-registry-puppet.j2.yaml | grep "OS::TripleO::Services::" | grep -v "OS::Heat::None"

# Remove ironic nodes manually and re-import
for i in `os baremetal node list | grep available | awk '{print $2}'`; do ironic node-set-provision-state $i deleted; done
for i in `os baremetal node list | grep available | awk '{print $2}'`; do ironic node-update $i remove instance_uuid; done
for i in `os baremetal node list | grep available | awk '{print $2}'`; do openstack baremetal node delete $i; done
openstack overcloud node import ~/instackenv.json
openstack overcloud node introspect --all-manageable --provide
