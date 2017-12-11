# vagrant-openstack

## What

Virtualized OSP 11 deployment using Vagrant and libvirt.

### Bare metal used

- ATX Desktop tower
- i7-4790K
- 32GB DDR3 RAM
- Linux Mint 18

### Tools

- ansible
- libvirt
- qemu
- vagrant
- vagrant-libvirt

### Networks

#### Controller

```
1. Provisioning / Control Plane
2. Storage
3. Storage Management
4. Internal API
5. Tenant
6. External
7. Baremetal 

1. 192.168.24.0/24
2. 192.168.34.0/24
3. 192.168.44.0/24
4. 192.168.54.0/24
5. 172.16.0.0/24
6. 10.0.0.0/24
7. 192.168.64.0/24
```

#### Compute

```
1. Provisioning / Control Plane
2. Storage
3. Internal API
4. Tenant

1. 192.168.24.0/24
2. 192.168.34.0/24
3. 192.168.54.0/24
4. 172.16.0.0/24
```

## Why

- No space or money to buy hardware
- Faster deployment times from zero to fully functioning Overcloud
- Test Director/Heat template creation
- Recreate typical Openstack failures and practice debugging
- Practice operating Openstack in a non-critical environment
- Mimic different network architectures virtually

## How

### Hypervisor setup

1. Setup SSH access

```shell
systemctl start sshd
```

2. Install Vagrant: https://www.vagrantup.com/

3. Install qemu and libvirt on your hypervisor: https://github.com/vagrant-libvirt/vagrant-libvirt#installation

4. Install vagrant-libvirt plugin: https://github.com/vagrant-libvirt/vagrant-libvirt#installation

```shell
vagrant plugin install vagrant-libvirt
```

5. Download the Vagrant box

```shell
wget http://file.rdu.redhat.com/\~hpawlows/rhel7.3-osp.box

vagrant box add rhel7.3-osp.box --name homeski/rhel7.3-osp
```

6. Clone the repository

```shell
git clone https://gitlab.cee.redhat.com/hpawlows/vagrant-openstack.git
cd vagrant-openstack
```

7. Setup your credentials for registering the systems.

You'll also need the pool-id that the system will register to. If you don't know, you can `vagrant ssh dir` into the box and run `subscription-manager list --available` to find a pool-id to use.

```
cp credentials.sample credentials

# Edit the file with your credentials
vim credentials
```

8. Bring up only the Director

```shell
vagrant up dir
```

9. Libvirt VirtualPowerManager setup

```shell
cat << EOF > /etc/polkit-1/localauthority/50-local.d/50-libvirt-user-stack.pkla
[libvirt Management Access]
Identity=unix-user:`whoami`
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF
```

### Undercloud installation

The following commands are pretty much copied from https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/10/html-single/director_installation_and_usage/.

1. SSH into the Director, add the initial user, subscribe the system, update and reboot

```shell
# SSH to box
vagrant ssh dir

# Change to Root
sudo su -

# Create stack user
useradd stack
echo pass | passwd stack --stdin

# Give stack user passwordless sudo
echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
chmod 0440 /etc/sudoers.d/stack

# Change to stack user
su - stack

# Register the system
sudo subscription-manager register --username=`grep username= /vagrant/credentials | cut -d '=' -f2` --password=`grep password= /vagrant/credentials | cut -d '=' -f2`
sudo subscription-manager attach --pool=`grep pool-id= /vagrant/credentials | cut -d '=' -f2`

sudo subscription-manager repos --disable=*
sudo subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-rh-common-rpms --enable=rhel-ha-for-rhel-7-server-rpms --enable=rhel-7-server-openstack-10-rpms

# Install packages and update
sudo yum install git vim tmux tree wget -y
sudo yum update -y
sudo reboot now
```

2. Setup the Undercloud

SSH into the Director, and install the Undercloud


```shell
vagrant ssh dir

sudo su - stack

sudo yum install python-tripleoclient -y

# Copy templates to stack's home directory
mkdir ~/images
cp -R /vagrant/osp10/ /home/stack/
cp /home/stack/osp10/undercloud/undercloud.conf /home/stack/
cp /home/stack/osp10/undercloud/instackenv.json /home/stack/

# Install Undercloud
time openstack undercloud install
# real    11m38.754s
# user    7m38.477s
# sys     0m56.079s

# Verify services started
sudo systemctl list-units openstack-*

source ~/stackrc

# Install images
sudo yum install rhosp-director-images rhosp-director-images-ipa -y

cd /home/stack/images
for i in /usr/share/rhosp-director-images/overcloud-full-latest-10.0.tar /usr/share/rhosp-director-images/ironic-python-agent-latest-10.0.tar; do
  tar -xvf $i;
done

openstack overcloud image upload --image-path /home/stack/images/

openstack image list
ls -l /httpboot

# Set DNS servers
openstack subnet set --dns-nameserver 192.168.121.1 --dns-nameserver 8.8.8.8 `openstack subnet list -c ID -f value`
```

3. Copy the SSH key to the hypervisor so that virtual IPMI works

```shell
# Run this from the Director

# It let's the Undercloud VM SSH into the hypervisor without a password
ssh-copy-id -i ~/.ssh/id_rsa.pub <hypervisor_user>@192.168.122.1
```

### Overcloud deployment

1. On the Hypervisor, bring up all the OSP nodes using Vagrant. **Note:** Bring the machines up 1 at a time, otherwise vagrant-libvirt seems to crash

```shell
vagrant up ctl1 && \
  vagrant up cpt1 && \
  vagrant up cpt2
```

2. In the `Vagrantfile`, all the NICs that the controllers and computes need are already setup.

**But,** Vagrant does something special and adds in an extra NIC as eth0. It uses this NIC to SSH into each machine. Director introspection and deployment expects eth0 to be the provisioning NIC, which causes issues. Here we remove the NIC added by Vagrant so introspection will work.

```shell
# Detach vagrant-libvirt NIC on all nodes
for node in ctl1 ctl2 ctl3 cpt1 cpt2; do
  virsh detach-interface vagrant-openstack_${node} network --persistent --mac `virsh dumpxml vagrant-openstack_${node} | grep -B4 vagrant-libvirt | grep mac | cut -d "'" -f2`
done
```

3. The following commands are pretty much copied from https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/10/html-single/director_installation_and_usage/.

SSH into the Director and deploy the overcloud

```shell
vagrant ssh dir

sudo su - stack

source stackrc

# Add MAC addresses to instackenv
# vi /home/stack/instackenv.json

# Find MAC address and save it to instackenv.json
for node in ctl1 ctl2 ctl3 cpt1 cpt2; do
  # Grab the MAC address of the node from the hypervisor
  MAC=$(ssh homeski@192.168.121.1 "virsh dumpxml vagrant-openstack_${node} 2> /dev/null | grep -B4 provisioning | grep mac | cut -d \"'\" -f2")\
  # Write the MAC address to the appropiate node and write to a tmp file
  jq "(.nodes[] | select(.name == \"${node}\") | .mac[0] ) = \"${MAC}\"" instackenv.json > instackenv.json.tmp
  # Save changes
  mv instackenv.json.tmp instackenv.json
done

# Filter out any nodes without a MAC address
jq '. | .nodes = [(.nodes[] | select(.mac[0] != ""))]' instackenv.json  > instackenv.json.tmp
mv instackenv.json.tmp instackenv.json

# Set the SSH key for IPMI
jq ". | .nodes[].pm_password = \"$(cat /home/stack/.ssh/id_rsa)\"" instackenv.json > instackenv.json.tmp
mv instackenv.json.tmp instackenv.json

# Import "baremetal"
openstack overcloud node import ~/instackenv.json
openstack baremetal node list

time openstack overcloud node introspect --all-manageable --provide
# real    3m4.432s
# user    0m0.417s
# sys     0m0.046s

openstack overcloud profiles list

cd /home/stack

./osp10/scripts/deploycmd.sh
# real    25m36.361s
# user    0m3.011s
# sys     0m0.251s
```

### Test the Overcloud

1. On the Director, deploy a test Heat stack using an already created template. This stack will test:

  - Instance creation works
  - Local image store using Glance works
  - Communication between two instances using the tenant network works
  - External communication via a floating IP works


```shell
vagrant ssh dir

sudo su - stack

source /home/stack/overcloudrc

# Download Cirros cloud image
wget http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img -O /home/stack/images/cirros-0.3.5-x86_64-disk.img

# Create Glance image
openstack image create "cirros" \
  --file /home/stack/images/cirros-0.3.5-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --public

# Launch the Heat stack which will create all the instances and networks needed
openstack stack create -t /home/stack/osp10/overcloud/heat/test-stack.yaml --parameter image_name=cirros test-stack1 --wait

# Get a KVM console into an instance and test
nova get-vnc-console test1 novnc
```

### Ironic on the Overcloud

```
vagrant ssh dir

sudo su - stack

source overcloudrc

# Configuring OpenStack networking

openstack network create \
  --provider-network-type flat \
  --provider-physical-network baremetal \
  --share baremetal-network

openstack subnet create \
  --network baremetal-network \
  --subnet-range 192.168.64.0/24 \
  --ip-version 4 \
  --gateway 192.168.64.1 \
  --allocation-pool start=192.168.64.10,end=192.168.64.20 \
  --dhcp baremetal-subnet

openstack router create baremetal-router

openstack router add subnet baremetal-router baremetal-subnet

# edit IronicCleaningNetwork in templates
# use ansible here ...
# cleaning_network = <None>
# systemctl restart openstack-ironic-conductor.service
source /home/stack/stackrc
ansible-playbook -i /home/stack/osp11/ansible/hosts.py -e "uuid=$(. /home/stack/overcloudrc; os network show baremetal-network -c id -f value)" /home/stack/osp11/ansible/playbook-ironic-overcloud.yaml  


## Creating the Baremetal flavor

source /home/stack/overcloudrc

openstack flavor create \
  --id auto --ram 1024  \
  --vcpus 1 --disk 40 \
  --property baremetal=true \
  --public baremetal

## Preparing the Deploy Images

openstack image create \
  --container-format aki \
  --disk-format aki \
  --public \
  --file /home/stack/images/ironic-python-agent.kernel bm-deploy-kernel

openstack image create \
  --container-format ari \
  --disk-format ari \
  --public \
  --file /home/stack/images/ironic-python-agent.initramfs bm-deploy-ramdisk

## Preparing the User Image

wget https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2 -O /home/stack/images/CentOS-7-x86_64-GenericCloud.qcow2

export DIB_LOCAL_IMAGE=/home/stack/images/CentOS-7-x86_64-GenericCloud.qcow2

disk-image-create centos7 baremetal -o centos-image

KERNEL_ID=$(openstack image create \
  --file centos-image.vmlinuz --public \
  --container-format aki --disk-format aki \
  -f value -c id centos-image.vmlinuz)

RAMDISK_ID=$(openstack image create \
  --file centos-image.initrd --public \
  --container-format ari --disk-format ari \
  -f value -c id centos-image.initrd)

openstack image create \
  --file centos-image.qcow2  --public \
  --container-format bare \
  --disk-format qcow2 \
  --property kernel_id=$KERNEL_ID \
  --property ramdisk_id=$RAMDISK_ID \
  centos-image

## Enrolling a Bare Metal Node With an Inventory File

# create file using jq here
## vagrant up node0
# Detach vagrant-libvirt NIC on all nodes
for node in node0 node1; do
  virsh detach-interface vagrant-openstack_${node} network --persistent --mac `virsh dumpxml vagrant-openstack_${node} | grep -B4 vagrant-libvirt | grep mac | cut -d "'" -f2`
done

FILE=/home/stack/osp11/overcloud/baremetal.json

# Find MAC address and save it to ${FILE}
for node in node0; do
  # Grab the MAC address of the node from the hypervisor
  MAC=$(ssh homeski@192.168.121.1 "virsh dumpxml vagrant-openstack_${node} 2> /dev/null | grep -B4 baremetal | grep mac | cut -d \"'\" -f2")\
  # Write the MAC address to the appropiate node and write to a tmp file
  jq "(.nodes[] | select(.name == \"${node}\") | .ports[0].address ) = \"${MAC}\"" ${FILE} > ${FILE}.tmp
  # Save changes
  mv ${FILE}.tmp ${FILE}
done

# Filter out any nodes without a MAC address
jq '. | .nodes = [(.nodes[] | select(.ports[0].address != ""))]' ${FILE}  > ${FILE}.tmp
mv ${FILE}.tmp ${FILE}

# Set the SSH key for IPMI
jq ". | .nodes[].driver_info.ssh_key_contents = \"$(cat /home/stack/.ssh/id_rsa)\"" ${FILE} > ${FILE}.tmp
mv ${FILE}.tmp ${FILE}

openstack baremetal create /home/stack/osp11/overcloud/baremetal.json

openstack baremetal node set node0 \
  --driver-info deploy_kernel=$(openstack image show bm-deploy-kernel -f value -c id) \
  --driver-info deploy_ramdisk=$(openstack image show bm-deploy-ramdisk -f value -c id)

openstack baremetal node list

# provide nodes here
openstack baremetal node manage node0
openstack baremetal node provide node0

## Using Host Aggregates to Separate Physical and Virtual Machine Provisioning

openstack flavor set baremetal --property baremetal=true

# openstack flavor set FLAVOR_NAME --property baremetal=false

openstack aggregate create --property baremetal=true baremetal-hosts
openstack aggregate create --property baremetal=false virtual-hosts

# openstack aggregate add host baremetal-hosts HOSTNAME
# openstack aggregate add host virtual-hosts HOSTNAME
openstack aggregate add host baremetal-hosts overcloud-controller-0.localdomain
openstack aggregate add host virtual-hosts overcloud-compute-0.localdomain 
openstack aggregate add host virtual-hosts overcloud-compute-1.localdomain 


```

### Acknowledgements

- https://keithtenzer.com/2015/10/14/howto-openstack-deployment-using-tripleo-and-the-red-hat-openstack-director/
- https://docs.openstack.org/tripleo-quickstart/latest/configuration.html#consuming-external-images
- https://mojo.redhat.com/groups/openstack-community-of-practice/projects/openstack-cop-pre-sales-track/blog/2016/09/21/try-out-open-stack-director-with-libvirt-vagrant-and-ansible
- https://gitlab.cee.redhat.com/kvanbesi/ospdlab
