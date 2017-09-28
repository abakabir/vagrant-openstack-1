#!/bin/python

import json
from subprocess import check_output
import re

# Get server list
text = check_output(["openstack", "server", "list", "-f", "json"])
json_data = json.loads(text)

# Init object
output = {
  'controllers': {
    'hosts': [],
    'vars': {
      'ansible_ssh_user': 'heat-admin',
      'ansible_become': 'yes'
    }
  },
  'computes': {
    'hosts': [],
    'vars': {
      'ansible_ssh_user': 'heat-admin',
      'ansible_become': 'yes'
    }
  }
}

# For each server returned by openstack command
for x in json_data:
  if re.search('controller', x['Name']) != None:
    # Find IP address with regex
    match = re.search('\d.*$', x['Networks']).group(0).encode('utf-8')
    # Append server
    output['controllers']['hosts'].append(match)
  elif re.search('compute', x['Name']) != None:
    # Find IP address with regex
    match = re.search('\d.*$', x['Networks']).group(0).encode('utf-8')
    # Append server
    output['computes']['hosts'].append(match)

# Print JSON
print output
