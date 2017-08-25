#!/bin/bash

time openstack overcloud deploy --templates \
  -e /home/stack/templates/environment/deployment.yaml \
  -e /home/stack/templates/environment/network-environment-multiple-nics.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml
