#!/bin/bash

. /home/stack/stackrc

time openstack overcloud deploy --templates \
  -e /home/stack/templates/environment/network-environment-multiple-nics.yaml \
  -e /home/stack/templates/environment/network-isolation.yaml \
  -e /home/stack/templates/environment/storage-environment.yaml \
  -e /home/stack/templates/environment/deployment.yaml \
  --ntp-server pool.ntp.org
