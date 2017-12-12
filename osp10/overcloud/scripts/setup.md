# Undercloud

```
su - stack

mkdir /home/stack/overcloud-database-backups

# use ansible to append to /etc/rsyncd.conf
[ overcloud]
path             = /home/stack/overcloud-database-backups
read only        = false
write only       = no
list             = yes
uid              = stack
gid              = stack
lock file        = /var/lock/overcloud-backups.lock

systemctl enable rsyncd
systemctl start rsyncd

```

# Overcloud

```
#!/bin/bash

# Parse MySQL info from /etc/nova/nova.conf
export mysql_host=$(crudini --get /etc/nova/nova.conf database connection | awk -F '[+:@/]' '{print $7}')
export mysql_user=$(crudini --get /etc/nova/nova.conf database connection | awk -F '[+:@/]' '{print $5}')
export mysql_pass=$(crudini --get /etc/nova/nova.conf database connection | awk -F '[+:@/]' '{print $6}')

# Get the active Galera target
galera_target=$(mysql --user=${mysql_user} --password=${mysql_pass} --host=${mysql_host} -e "show variables like 'hostname';" --silent --skip-column-names | cut -f2)

if [[ ${galera_target} == $(hostname) ]]; then
  echo 'Not backing up $(hostname) because it is the current Galera target node...'
  exit 1
fi

# Make sure this host is syned with Galera.
# The grep command will return 0 if 'not synced' is NOT found
# in the string.
curl -s $(hostname).localdomain:9200 | grep -v 'not synced' -q

if [[ $? == 0 ]]; then
  echo 'Ready to backup database...'
else
  echo 'Not backing up $(hostname) because it is not synced with Galera...'
  exit 1
fi

```




```
# this will copy all local files into remote directory
crontab -e 
* * * * * rsync -avz test-files/ 192.168.24.2::overcloud

```