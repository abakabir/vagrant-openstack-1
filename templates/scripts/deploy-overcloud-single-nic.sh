#!/bin/bash

time openstack overcloud deploy --templates \
  -e /home/stack/templates/environment/deployment.yaml \
  -e /home/stack/templates/environment/network-environment-single-nic.yaml
