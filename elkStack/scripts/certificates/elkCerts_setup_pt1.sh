#!/bin/bash -x

cd /usr/share/elasticsearch

#printf '\n%s\n' "$cert_PW"| sudo $usrElastic/bin/elasticsearch-certutil ca

sudo $usrElastic/bin/elasticsearch-certutil ca --out $usrElastic/elastic-stack-ca.p12 --pass $ca_PW 

#printf 'admin1\n\nadmin1\n' | sudo $usrElastic/bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12

sudo $usrElastic/bin/elasticsearch-certutil cert \
--ca $usrElastic/elastic-stack-ca.p12 \
--ca-pass $ca_PW \
--out $usrElastic/elastic-certificates.p12 \
--pass $cert_PW

sudo chown root:elasticsearch $usrElastic/elastic-certificates.p12
sudo chmod 660 $usrElastic/elastic-certificates.p12
sudo mv $usrElastic/elastic-certificates.p12 $etcElastic

sudo $usrElastic/bin/elasticsearch-keystore add \
xpack.security.transport.ssl.keystore.secure_password \
xpack.security.transport.ssl.truststore.secure_password \
xpack.security.http.ssl.keystore.secure_password \
xpack.security.http.ssl.truststore.secure_password \
--pw $cert_PW

### WRITE THE PASSWORDS TO FILE, JUST CHECKING TO SEE IF IT WORKS:
sudo $usrElastic/bin/elasticsearch-keystore show \
xpack.security.transport.ssl.keystore.secure_password >> /home/ubuntu/passwords.txt

sudo $usrElastic/bin/elasticsearch-keystore show \
xpack.security.transport.ssl.truststore.secure_password >> /home/ubuntu/passwords.txt

sudo $usrElastic/bin/elasticsearch-keystore show \
xpack.security.http.ssl.keystore.secure_password >> /home/ubuntu/passwords.txt

sudo $usrElastic/bin/elasticsearch-keystore show \
xpack.security.http.ssl.truststore.secure_password >> /home/ubuntu/passwords.txt

#printf 'y\nadmin1\n' \
#| sudo $usrElastic/bin/elasticsearch-keystore add \
#xpack.security.transport.ssl.keystore.secure_password

#printf 'y\nadmin1\n' \
#| sudo $usrElastic/bin/elasticsearch-keystore add \
#xpack.security.transport.ssl.truststore.secure_password

#printf 'y\nadmin1\n' \
#| sudo $usrElastic/bin/elasticsearch-keystore add \
#xpack.security.http.ssl.keystore.secure_password

#printf 'admin1\n' \
#| sudo ./bin/elasticsearch-keystore add \
#xpack.security.http.ssl.truststore.secure_password
