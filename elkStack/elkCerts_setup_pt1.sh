#!/bin/bash -x

cd /usr/share/elasticsearch
printf '\nadmin1\n' | sudo ./bin/elasticsearch-certutil ca

printf 'admin1\n\nadmin1\n' | sudo ./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12
sudo chown root:elasticsearch elastic-certificates.p12
sudo chmod 660 elastic-certificates.p12
sudo mv elastic-certificates.p12 /etc/elasticsearch

printf 'y\nadmin1\n' \
| sudo ./bin/elasticsearch-keystore add \
xpack.security.transport.ssl.keystore.secure_password

printf 'y\nadmin1\n' \
| sudo ./bin/elasticsearch-keystore add \
xpack.security.transport.ssl.truststore.secure_password

printf 'y\nadmin1\n' \
| sudo ./bin/elasticsearch-keystore add \
xpack.security.http.ssl.keystore.secure_password

printf 'admin1\n' \
| sudo ./bin/elasticsearch-keystore add \
xpack.security.http.ssl.truststore.secure_password
