#!/bin/bash

# --------------------------- #
# --- Boot first instance --- #
# --------------------------- #

openstack flavor create --vcpus 1 --ram 512 --disk 1 m1.nano
openstack flavor create --vcpus 1 --ram 512 --disk 10 m1.micro

cd /home/stack/images
wget http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img
wget http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2

openstack image create "cirros" \
  --file cirros-0.3.5-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --public

openstack image create "centos7" \
  --file CentOS-7-x86_64-GenericCloud.qcow2 \
  --disk-format qcow2 --container-format bare \
  --public

# Test tenant networking
# openstack network create tenant
# openstack subnet create tenant --network tenant --dhcp --allocation-pool start=172.16.0.20,end=172.16.0.50 --gateway 172.16.0.1 --subnet-range 172.16.0.0/24 --dns-nameserver 8.8.8.8
# openstack server create --flavor m1.nano --nic net-id=`openstack network list | grep tenant | awk '{print $2}'` --image cirros test1
# openstack server create --flavor m1.nano --nic net-id=`openstack network list | grep tenant | awk '{print $2}'` --image cirros test2

# Test external networking using floating IPs
# openstack network create public --share --external --provider-network-type flat --provider-physical-network datacentre
# openstack subnet create public --network public --dhcp --allocation-pool start=10.0.0.20,end=10.0.0.50 --gateway 10.0.0.1 --subnet-range 10.0.0.0/24 --dns-nameserver 8.8.8.8
#
# openstack router create public
# openstack router set public --external-gateway public
# openstack router add subnet public tenant
# openstack floating ip create --port `os port list --server test1 -f value -c ID` public

openstack stack create -t /home/stack/templates/heat/test-stack.yaml --parameter image_name=cirros test-stack1

# ----------------------- #
# --- Useful commands --- #
# ----------------------- #

# Monitor hypervisor info
watch 'free -h; echo ""; df -h; echo ""; virsh list; echo ""; ps aux  | awk '\''{print $6/1024 " MB\t\t" $11}'\''  | sort -n | tail'

# Show process MB usage
ps aux  | awk '{print $6/1024 " MB\t\t" $11}'  | sort -n

# Delete all baremetal servers
for i in `os baremetal node list | grep available | awk '{print $2}'`; do os baremetal node delete $i; done

# Show default services
cat /usr/share/openstack-tripleo-heat-templates/overcloud-resource-registry-puppet.j2.yaml | grep "OS::TripleO::Services::" | grep -v "OS::Heat::None"

# Remove ironic nodes manually and re-import
for i in `os baremetal node list | grep available | awk '{print $2}'`; do ironic node-set-provision-state $i deleted; done
for i in `os baremetal node list | grep available | awk '{print $2}'`; do ironic node-update $i remove instance_uuid; done
for i in `os baremetal node list | grep available | awk '{print $2}'`; do openstack baremetal node delete $i; done
openstack overcloud node import ~/instackenv.json
openstack overcloud node introspect --all-manageable --provide
