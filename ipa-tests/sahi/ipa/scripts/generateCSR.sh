#!/bin/bash
MYHOST=$1
PWDFILE="/tmp/pwdfile.txt"

# SSL setup
# generate a noise file for key generation
echo "Creating noise file ....................................................."
echo "kjasero;uae8905t76V)e6v7q4wy58w4a5;7t90r798bv2[578rbvr7b90w7rbaw0 brwb7yfbz7rv6vawp9" > /tmp/noise.txt

# generate a password file for cert database
echo "Creating password file...................................................."
echo "Secret123" > $PWDFILE

# create cert db and certificates
cd /tmp
certutil -d . -N -f $PWDFILE

# Get certificate subject
certsubj=`ipa config-show | grep "Certificate Subject base" | cut -d ":" -f2`
# trim whitespace
certsubj=`echo $certsubj`

# generate a certificate request for the host machine
certutil -R -s "CN=$MYHOST,$certsubj" -d . -a -z /tmp/noise.txt -f $PWDFILE > $MYHOST.csr
cat $MYHOST.csr
