#!/bin/bash

useradd stack
passwd stack

echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack

# ---

su - stack

mkdir ~/images
mkdir ~/templates

sudo subscription-manager register
sudo subscription-manager attach --pool=`cat ./pool-id`

sudo subscription-manager repos --disable=*
sudo subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-rh-common-rpms --enable=rhel-ha-for-rhel-7-server-rpms --enable=rhel-7-server-openstack-11-rpms

sudo yum install git vim tmux tree -y
sudo yum update -y
sudo reboot now

# ---

su - stack

sudo ip link set up eth2

sudo yum install -y python-tripleoclient

touch /home/stack/undercloud.conf

openstack undercloud install
