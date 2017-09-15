#!/bin/bash

# ------------------------ #
# --- Deploy Overcloud --- #
# ------------------------ #

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