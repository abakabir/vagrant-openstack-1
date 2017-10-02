#!/bin/bash

. /home/stack/stackrc

time openstack overcloud deploy --templates \
  -e /home/stack/osp11/templates/environment/network-environment-multiple-nics.yaml \
  -e /home/stack/osp11/templates/environment/network-isolation.yaml \
  -e /home/stack/osp11/templates/environment/storage-environment.yaml \
  -e /home/stack/osp11/templates/environment/deployment.yaml \
  --ntp-server pool.ntp.org

# -e /home/stack/osp11/templates/environment/enable-tls.yaml \
# -e /home/stack/osp11/templates/environment/inject-trust-anchor.yaml \
# -e /usr/share/openstack-tripleo-heat-templates/environments/tls-endpoints-public-ip.yaml \

