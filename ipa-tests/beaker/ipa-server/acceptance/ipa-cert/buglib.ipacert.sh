#!/bin/bash

create_openssl_cnf()
{
    local file=$1
    local altname=$2
    cat > $file << EOF
[req]
default_bits = 2048
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no
encrypt_key = no

[req_distinguished_name]
countryName = US
stateOrProvinceName = CA
localityName = Mountain View
0.organizationName = RedHat
organizationalUnitName = QA
commonName = $altname
emailAddress = testbug@qa.redhat.com

[ v3_req ]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $altname

EOF
}
