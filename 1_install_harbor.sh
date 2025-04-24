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
HARBORFQDN=$(hostname)
    
HARBORIP=$(ip add show dev eth0 |grep "inet "|awk '{print $2}'|cut -d "/" -f1)
read -s -p "Please enter harbor admin password: " HARBORADMINPWD
echo
echo "host: $HARBORFQDN"
echo "ip : $HARBORIP"
echo "pwd: $HARBORADMINPWD"
export HARBORFQDN
export HARBORIP
export HARBORADMINPWD

./generate_ssl_cert.sh "${HARBORFQDN}" "${HARBORIP}"
sudo cp ${HARBORFQDN}.crt /opt/harbor
sudo cp ${HARBORFQDN}.key /opt/harbor

HARBORFQDN=$(hostname)

if [ "${HARBORADMINPWD}" == "" ]; then
    read -s -p "Please enter password you want to set for harbor admin : " HARBORADMINPWD
fi

sudo cp /opt/harbor/harbor.yml.tmpl /opt/harbor/harbor.yml
sudo harborfqdn="${HARBORFQDN}" yq -i '.hostname = strenv(harborfqdn)' /opt/harbor/harbor.yml
sudo harborcert="/opt/harbor/${HARBORFQDN}.crt" yq -i '.https.certificate = strenv(harborcert)' /opt/harbor/harbor.yml
sudo harborkey="/opt/harbor/${HARBORFQDN}.key" yq -i '.https.private_key = strenv(harborkey)' /opt/harbor/harbor.yml
sudo harboradminpwd="${HARBORADMINPWD}" yq -i '.harbor_admin_password = strenv(harboradminpwd)' /opt/harbor/harbor.yml
sudo harboradminpwd="${HARBORADMINPWD}" yq -i '.database.password = strenv(harboradminpwd)' /opt/harbor/harbor.yml
sudo yq e /opt/harbor/harbor.yml

echo "press enter to continue"
read -r
sudo /opt/harbor/install.sh
if [ $? -ne 0 ]; then
    echo "Installation failed. Exiting."
    exit 1
fi
echo "Installation complete"
echo "checking harbor status"
watch docker ps
