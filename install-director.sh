#!/bin/bash

# Following documentation at:
# https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/11/html-single/director_installation_and_usage/

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

sudo yum install python-tripleoclient -y

touch /home/stack/undercloud.conf

openstack undercloud install

# ---

su - stack

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

openstack subnet set --dns-nameserver 192.168.121.1 --dns-nameserver 8.8.8.8 `openstack subnet list | grep 192.168.26 | awk '{print $2}'`

# ---

# on director

ssh-copy-id -i ~/.ssh/id_rsa.pub homeski@192.168.122.1 # -p23

# host KVM machine
cat << EOF > /etc/polkit-1/localauthority/50-local.d/50-libvirt-user-stack.pkla
[libvirt Management Access]
Identity=unix-user:homeski
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF

# ctl1 52:54:00:a6:dd:42 52:54:00:2a:9d:df
# cpt1 52:54:00:d9:84:6f 52:54:00:81:d8:1d

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
        "52:54:00:2a:9d:df"
      ],
      "cpu": "4",
      "memory": "4096",
      "disk": "60",
      "arch": "x86_64",
      "pm_user": "homeski"
    },
    {
      "pm_addr": "192.168.122.1",
      "pm_password": "$(cat ~/.ssh/id_rsa)",
      "pm_type": "pxe_ssh",
      "mac": [
        "52:54:00:81:d8:1d"
      ],
      "cpu": "4",
      "memory": "4096",
      "disk": "60",
      "arch": "x86_64",
      "pm_user": "homeski"
    }
  ]
}
EOF

openstack overcloud node import ~/instackenv.json
openstack baremetal node list

# comment out eth0 on KVM domain on host

openstack overcloud node introspect --all-manageable --provide

# ---

openstack baremetal node set --property capabilities='profile:control,boot_option:local' 3fa31610-d54c-4ef0-9853-5e05cff657c7
openstack baremetal node set --property capabilities='profile:compute,boot_option:local' 04435321-9cbe-439b-ad59-b90cb38669b3

openstack flavor delete compute
openstack flavor create --id auto --ram 1024 --disk 40 --vcpus 1 compute
openstack flavor set --property "capabilities:boot_option"="local" --property "capabilities:profile"="compute" compute

openstack flavor delete control
openstack flavor create --id auto --ram 1024 --disk 40 --vcpus 1 control
openstack flavor set --property "capabilities:boot_option"="local" --property "capabilities:profile"="control" control

openstack flavor delete baremetal
openstack flavor create --id auto --ram 1024 --disk 40 --vcpus 1 baremetal
openstack flavor set --property "capabilities:boot_option"="local" baremetal

touch /home/stack/deployment.yaml

time openstack overcloud deploy --templates \
  -e ~/deployment.yaml
