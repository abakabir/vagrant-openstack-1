#!/bin/bash

time openstack overcloud deploy --templates \
  -e /home/stack/vagrant-openstack/templates/deployment.yaml \
  -e /home/stack/vagrant-openstack/templates/network-environment.yaml 
