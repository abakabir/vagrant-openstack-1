#!/bin/bash

time openstack overcloud deploy --templates \
  -e /home/stack/osp11/templates/environment/deployment.yaml \
  -e /home/stack/osp11/templates/environment/network-environment-single-nic.yaml
