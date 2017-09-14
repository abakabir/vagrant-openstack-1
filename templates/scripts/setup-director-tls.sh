#!/bin/bash

# Run the commands to setup TLS/SSL on the Director Undercloud.
# These commands should be ran once before the initial overcloud deployment.
# Make sure to update the templates if they are ever ran again.

# https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/10/html/advanced_overcloud_customization/sect-enabling_ssltls_on_the_overcloud

cd /home/stack

# The /etc/pki/CA/index.txt file stores records of all signed certificates.
sudo touch /etc/pki/CA/index.txt

# The /etc/pki/CA/serial file identifies the next serial number to use for the next certificate to sign
sudo echo '1000' | sudo tee /etc/pki/CA/serial

# CREATING A CERTIFICATE AUTHORITY
openssl genrsa -out ca.key.pem 4096
openssl req  -key ca.key.pem -new -x509 -days 7300 -extensions v3_ca -out ca.crt.pem

# CREATING AN SSL/TLS KEY
openssl genrsa -out server.key.pem 2048

# CREATING AN SSL/TLS CERTIFICATE SIGNING REQUEST
# cp /etc/pki/tls/openssl.cnf .
cp /home/stack/templates/environment/openssl.cnf .

# Run the following command to generate certificate signing request
openssl req -config openssl.cnf -key server.key.pem -new -out server.csr.pem

# CREATING THE SSL/TLS CERTIFICATE
sudo openssl ca -config openssl.cnf -extensions v3_req -days 3650 -in server.csr.pem -out server.crt.pem -cert ca.crt.pem -keyfile ca.key.pem

# ENABLING SSL/TLS
# Copy the contents of the certificate file into the SSLCertificate parameter
# Copy the contents of the private key into the SSLKey parameter
# vi /home/stack/templates/environment/enable-tls.yam

# INJECTING A ROOT CERTIFICATE
# Copy the contents of the root certificate authority file into the SSLRootCertificate parameter
# vi /home/stack/environment/inject-trust-anchor.yaml