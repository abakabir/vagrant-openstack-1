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
MIIDcTCCAlmgAwIBAgIQTZca5nAaTLtGaSGsiEgKQjANBgkqhkiG9w0BAQUFADBL
MRMwEQYKCZImiZPyLGQBGRYDQ09NMRYwFAYKCZImiZPyLGQBGRYGUkVESEFUMRww
GgYDVQQDExNSRURIQVQtV0lOMksxMlIyLUNBMB4XDTE3MDQxMzAxNTMxM1oXDTIy
MDQxMzAyMDMxMlowSzETMBEGCgmSJomT8ixkARkWA0NPTTEWMBQGCgmSJomT8ixk
ARkWBlJFREhBVDEcMBoGA1UEAxMTUkVESEFULVdJTjJLMTJSMi1DQTCCASIwDQYJ
KoZIhvcNAQEBBQADggEPADCCAQoCggEBAKjqv5n6e+C8Jcv5EeQWTFF6pxqOlfmr
sRjgveviuDJUceFWmzJGAy0L7VekDT6InV+21XEo7SdcFjMoDMyIoKoWIF6sO2Yk
Q7p7rw1XdDw0ZglaDc+49XbRgZrAM99zvd/hxClHOs4QqlKcMmMpTD52f+lz4Unh
lrDv9Bu0hAsokz1sC3eylrCCd4fI5FRRbfhgxho4k2JH9VqTdjtQH0U7bR+Npjmt
uUsjP5NX2vqly4jaYe75S6H2XqzHk6hQUCDiFbwxWE3eVcHwVhnemFAoIzE5n4YD
ilNTv6Xaxk9RlyzUBML3u1fjQwZGuTx7JJnKGlWwVtRMxHI3b+rf5I8CAwEAAaNR
ME8wCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFE2jQp60
xdGm0nkkY1uGINE2E5O+MBAGCSsGAQQBgjcVAQQDAgEAMA0GCSqGSIb3DQEBBQUA
A4IBAQB96+6P/LaB652F5PVSw1bs3n1euLc4yiy3AcOhfIIbSHBd1og6G84eyGR7
K2WlEwAk8pT/SPxowAVth0mF+iEXv0W3qdAZKw2mTjC2AuGKdF/VjWnwZufFsczE
aonTb7MVA44rlAGmL1Ys5uEVl7MBNpfNYALAu+un46poJiVgLvZe5pLojxO2CTIw
G3bhOCxXF3Xcx/ECJ2RcIsiXpHFz3naH9hbNkSbT5XIJ0A2LnM7cm9jxO+jJ4wD8
Dcl54fwyj1re+SNhc1WE16PLInLOOXpQgZ1aF32Mb693wrlzrwHcWVhmKB5f7h/C
yeRjMIKKJFMTU2LRyaasKYKXPbs5
-----END CERTIFICATE-----' > /etc/ssl/certs/addc.lab.local.crt
