#!/bin/bash

. /home/stack/stackrc

time openstack overcloud deploy --templates \
  -e /home/stack/osp10/templates/node-info.yaml \
  -e /home/stack/osp10/templates/network-environment-multiple-nics.yaml \
  -e /home/stack/osp10/templates/network-isolation.yaml \
  -e /home/stack/osp10/templates/storage-environment.yaml \
  -e /home/stack/osp10/templates/services/ironic.yaml \
  -e /home/stack/osp10/templates/ldap-environment.yaml \
  --ntp-server pool.ntp.org

# -e /home/stack/osp11/templates/environment/enable-tls.yaml \
# -e /home/stack/osp11/templates/environment/inject-trust-anchor.yaml \
# -e /usr/share/openstack-tripleo-heat-templates/environments/tls-endpoints-public-ip.yaml \

