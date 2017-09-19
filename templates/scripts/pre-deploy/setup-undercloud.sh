#!/bin/bash

# -------------------------- #
# --- Install Undercloud --- #
# -------------------------- #

# Following documentation at:
# https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/11/html-single/director_installation_and_usage/

# Add stack user

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

ssh-copy-id -i ~/.ssh/id_rsa.pub homeski@192.168.122.1