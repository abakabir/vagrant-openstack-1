#!/bin/bash -x

mkdir -p /opt/stack/puppet-modules/tripleoldap/manifests/

cat <<'EOF' >> /opt/stack/puppet-modules/tripleoldap/manifests/init.pp
class tripleoldap ($ldap = undef){
  if $ldap {
    create_resources('::keystone::ldap_backend', $ldap)
  }
}
EOF

setsebool -P authlogin_nsswitch_use_ldap=on 2>/dev/null

echo '-----BEGIN CERTIFICATE-----
sadasd
-----END CERTIFICATE-----' > /etc/ssl/certs/addc.lab.local.crt
