#!/bin/bash

virsh net-start provisioning
virsh net-start storage
virsh net-start storage-mgmt
virsh net-start internal-api
virsh net-start tenant
virsh net-start external
virsh net-start baremetal

