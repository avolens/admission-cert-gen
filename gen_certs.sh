#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# CREATE THE PRIVATE KEY FOR OUR CUSTOM CA
openssl genrsa -out certs/ca.key 4096

# GENERATE A CA CERT WITH THE PRIVATE KEY
openssl req -new -x509 -key certs/ca.key -out certs/ca.crt -config ca_config.txt

# CREATE THE PRIVATE KEY FOR OUR GRUMPY SERVER
openssl genrsa -out certs/admission-key.pem 2048

# CREATE A CSR FROM THE CONFIGURATION FILE AND OUR PRIVATE KEY
openssl req -new -key certs/admission-key.pem -subj "/CN=*.cylens-dev.svc" -out certs/admission.csr -config cert_config.txt

# CREATE THE CERT SIGNING THE CSR WITH THE CA CREATED BEFORE
openssl x509 -req -in certs/admission.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/admission-crt.pem -extfile cert_config.txt -extensions v3_req

# OUTPUT
cat certs/ca.crt | base64 | tr -d '\n' > ca_bundle
echo ca_bundle generated.

cat certs/admission-crt.pem | base64 | tr -d '\n' > tls.crt
echo tls.crt generated.

cat certs/admission-key.pem | base64 | tr -d '\n' > tls.key
echo tls.key generated.
