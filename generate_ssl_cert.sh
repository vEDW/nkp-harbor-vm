
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
DOMAIN="$1"
IP_ADDRESS="$2"
DAYS=365
KEY_FILE="${DOMAIN}.key"
CERT_FILE="${DOMAIN}.crt"
CSR_FILE="${DOMAIN}.csr"
CONFIG_FILE="openssl.cnf"
COUNTRY="US"    #2 letters country code
STATE="CA"      #2 letters State Code
ORGANISATION="Nutanix"
ORGANISATIONUNIT="Nutanix"

EMAIL=""


# Create OpenSSL configuration file
cat > "$CONFIG_FILE" <<EOL
[req]
default_bits = 4096
default_md = sha512
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
C = $COUNTRY
ST = $STATE
L = City
O = $ORGANISATION
OU = $ORGANISATIONUNIT
CN = $DOMAIN

[v3_req]
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=$DOMAIN
IP.1=$IP_ADDRESS

EOL


openssl req -out $CSR_FILE -new -newkey rsa:2048 -nodes -sha256  -keyout $KEY_FILE 

openssl x509 -req -days 9999 -in $CSR_FILE -sha256 -signkey $KEY_FILE -out $CERT_FILE -extfile $CONFIG_FILE


# Generate a private key
#openssl genrsa -out "$KEY_FILE" 2048
# openssl genrsa -out ca.key 4096

# openssl req -x509 -new -nodes -sha512 -days $DAYS \
#  -subj "/C=$COUNTRY/ST=$STATE/L=City/O=$ORGANISATION/OU=$ORGANISATIONUNIT/CN=$DOMAIN" \
#  -key ca.key \
#  -out ca.crt

# # Generate a self-signed certificate using the config file
# #openssl req -new -x509 -noenc -key "$KEY_FILE" -out "$CERT_FILE" -days "$DAYS" -config "$CONFIG_FILE"

# #openssl x509 -inform PEM -in yourdomain.com.crt -out yourdomain.com.cert

# # # 1. Generate CA's private key and self-signed certificate
# openssl req -x509 -newkey rsa:4096 -days $DAYS -nodes -keyout ca-key.pem -out ca-cert.pem -subj "/C=$COUNTRY/ST=$STATE/L=City/O=$ORGANISATION/OU=$ORGANISATIONUNIT/CN=$DOMAIN"
# #openssl req -x509 -newkey rsa:4096 -days $DAYS -nodes -keyout ca-key.pem -out ca-cert.pem -config "$CONFIG_FILE"

# # echo "CA's self-signed certificate"
# openssl x509 -in ca-cert.pem -noout -text

# # # 2. Generate web server's private key and certificate signing request (CSR)
# #openssl req -newkey rsa:4096 -keyout server-key.pem -out server-req.pem -subj "/C=NG/ST=Rivers/L=PHC/O=Mono Finance/OU=Finance/CN=*.monofinance.net/emailAddress=mrikehchukwuka@gmail.com"
# openssl req -newkey rsa:4096 -keyout server-key.pem -out server-req.pem -config "$CONFIG_FILE"

# # # 3. Use CA's private key to sign web server's CSR and get back the signed certificate
# openssl x509 -req -in server-req.pem -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -days $DAYS -extfile server-ext.cnf

# # echo "Server's signed certificate"
# openssl x509 -in server-cert.pem -noout -text

# echo "Command to verify Server and CA certificates"
# openssl verify -CAfile ca-cert.pem server-cert.pem

# Clean up the configuration file after use
#rm "$CONFIG_FILE"

#openssl x509 -in $CERT_FILE -text -noout

echo
echo "Certificate and key generated:"
echo "Key: $KEY_FILE"
echo "Certificate: $CERT_FILE"
