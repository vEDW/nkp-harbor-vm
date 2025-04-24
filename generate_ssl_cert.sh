#!/usr/bin/env bash

#------------------------------------------------------------------------------

# Copyright 2024 Nutanix, Inc
#
# Licensed under the MIT License;
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”),
# to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#------------------------------------------------------------------------------

# Maintainer:   Eric De Witte (eric.dewitte@nutanix.com)
# Contributors: 

#------------------------------------------------------------------------------

# Check if a domain name and an IP address are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <harborfqdn> <ip-address>"
    exit 1
fi

# Variables
FQDN="$1"
IP_ADDRESS="$2"
HOSTNAME=$(echo $FQDN | cut -d '.' -f 1)
# Extract the domain name from the FQDN
DOMAIN=$(echo $FQDN | cut -d '.' -f 2-)
DAYS=365
KEY_FILE="${FQDN}.key"
CERT_FILE="${FQDN}.crt"
CSR_FILE="${FQDN}.csr"
CONFIG_FILE="${FQDN}.cnf"
COUNTRY="US"    #2 letters country code
STATE="CA"      #2 letters State Code
ORGANISATION="Nutanix"
ORGANISATIONUNIT="Nutanix"

EMAIL=""

openssl req -new -newkey rsa:2048 -nodes -sha256 -subj "/C=$COUNTRY/ST=$STATE/L=City/O=$ORGANISATION/OU=$ORGANISATIONUNIT/CN=$DOMAIN"  -out "$CSR_FILE" -keyout $KEY_FILE

# Create OpenSSL configuration file
cat > v3.ext <<EOL
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
basicConstraints=CA:TRUE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement, keyCertSign
extendedKeyUsage = serverAuth
subjectAltName = DNS:*.$DOMAIN,DNS:$HOSTNAME,DNS:$FQDN,IP:$IP_ADDRESS

EOL

openssl x509 -req -sha256 -days 3650 -extfile v3.ext -signkey $KEY_FILE -in "$CSR_FILE" -out "$CERT_FILE"

openssl x509 -text -noout -in $CERT_FILE 
openssl x509 -inform PEM -in $CERT_FILE -out ${FQDN}.cert

echo
echo "Certificate and key generated:"
echo "Key: $KEY_FILE"
echo "Certificate: $CERT_FILE"
