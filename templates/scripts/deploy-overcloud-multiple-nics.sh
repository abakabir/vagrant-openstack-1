#!/bin/bash

time openstack overcloud deploy --templates \
  -e /home/stack/templates/environment/network-environment-multiple-nics.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
  -e /home/stack/templates/environment/storage-environment.yaml \
  -e /home/stack/templates/environment/services.yaml \
  -e /home/stack/templates/environment/low-memory-usage.yaml \
  -e /home/stack/templates/environment/deployment.yaml \
  --ntp-server pool.ntp.org
