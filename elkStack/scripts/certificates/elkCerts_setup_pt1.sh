#!/bin/bash -x

sudo $usrElastic/bin/elasticsearch-certutil ca --out $usrElastic/elastic-stack-ca.p12 --pass $ca_PW 

sudo $usrElastic/bin/elasticsearch-certutil cert \
--ca $usrElastic/elastic-stack-ca.p12 \
--ca-pass $ca_PW \
--out $usrElastic/elastic-certificates.p12 \
--pass $cert_PW

sudo chown root:elasticsearch $usrElastic/elastic-certificates.p12
sudo chmod 660 $usrElastic/elastic-certificates.p12
sudo mv $usrElastic/elastic-certificates.p12 $etcElastic

echo "${cert_PW}" | sudo $usrElastic/bin/elasticsearch-keystore add -f \
xpack.security.transport.ssl.keystore.secure_password --stdin

echo "${cert_PW}" | sudo $usrElastic/bin/elasticsearch-keystore add -f \
xpack.security.transport.ssl.truststore.secure_password --stdin

echo "${cert_PW}" | sudo $usrElastic/bin/elasticsearch-keystore add -f \
xpack.security.http.ssl.keystore.secure_password --stdin

sudo $usrElastic/bin/elasticsearch-keystore create xpack.security.http.ssl.truststore.secure_password

echo "${cert_PW}" | sudo $usrElastic/bin/elasticsearch-keystore add -f \
xpack.security.http.ssl.truststore.secure_password --stdin


# Writes the passwords in the keystores to file. Uncomment below if you require it for errorchecking
write_pw_to_file() {
    touch /home/ubuntu/passwords.txt
    sudo $usrElastic/bin/elasticsearch-keystore show \
    xpack.security.transport.ssl.keystore.secure_password \
    | { tr -d '\n'; echo " "; } >> /home/ubuntu/passwords.txt

    sudo $usrElastic/bin/elasticsearch-keystore show \
    xpack.security.transport.ssl.truststore.secure_password \
    | { tr -d '\n'; echo " "; } >> /home/ubuntu/passwords.txt

    sudo $usrElastic/bin/elasticsearch-keystore show \
    xpack.security.http.ssl.keystore.secure_password \
    | { tr -d '\n'; echo " "; } >> /home/ubuntu/passwords.txt

    sudo $usrElastic/bin/elasticsearch-keystore show \
    xpack.security.http.ssl.truststore.secure_password \
    | { tr -d '\n'; echo " "; } >> /home/ubuntu/passwords.txt
}

write_pw_to_file
