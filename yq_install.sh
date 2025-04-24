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

YQRELEASE=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r .tag_name)
if [[ ${YQRELEASE} == "null" ]]; then
    echo "github api rate limiting blocked request"
    echo "get latest version failed. Exiting."
    exit 1
fi

echo "Downloading yq ${YQRELEASE}"
curl -s -LO https://github.com/mikefarah/yq/releases/download/${YQRELEASE}/yq_linux_amd64.tar.gz
if [ $? -ne 0 ]; then
    echo "Download failed. Exiting."
    exit 1
fi
echo "Download complete"

echo "extracting yq"
mkdir yq
tar -zxf yq_linux_amd64.tar.gz --directory=./yq/
if [ $? -ne 0 ]; then
    echo "Extraction failed. Exiting."
    exit 1
fi
sudo mv ./yq/yq_linux_amd64 /usr/local/bin/yq
rm -rf ./yq/
yq --version
