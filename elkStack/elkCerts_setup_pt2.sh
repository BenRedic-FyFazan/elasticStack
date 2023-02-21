‹#!/bin/bash -x
## Required for keytool
sudo apt install -y openjdk-17-jre-headless 
## Getting ip address to variable
ip4=$(/sbin/ip -o -4 addr list ens3 | awk '{print $4}' | cut -d/ -f1)

cd /usr/share/elasticsearch

# Generate CSR -> Use an existing CA?
# CA path -> Password for CA -> 
# Cert validity period -> certificate per node -> nodename -> hostnames
# Made changes, need to update these comments
printf 'n\ny\n \
/usr/share/elasticsearch/elastic-stack-ca.p12\nadmin1\n \
5y\ny\nnode-1\nelkStack\nlocalhost\n\n\ny\n%s\n127.0.0.1\n\ny\nn\nn\nadmin1\nadmin1\n\n' $ip4 \
| sudo ./bin/elasticsearch-certutil http

# Unzipping, moving, setting rights and copying http.p12
sudo unzip elasticsearch-ssl-http.zip 
sudo mv ./elasticsearch/http.p12 /etc/elasticsearch/http.p12
sudo chmod 664 /etc/elasticsearch/http.p12
sudo cp /etc/elasticsearch/http.p12 /etc/kibana/http.p12
printf 'y\nadmin1\n' | sudo ./bin/elasticsearch-keystore add xpack.security.http.ssl.keystore.secure_password

#printf 'y\nadmin1\n' | sudo /usr/share/kibana/bin/kibana-keystore add xpack.security.server.ssl.keystore.secure_password

#xpack.security.http.ssl.keystore.secure_password

# Moving, setting rights and copying elasticsearch-ca.pem 
sudo mv ./kibana/elasticsearch-ca.pem /etc/elasticsearch/elasticsearch-ca.pem
sudo chmod 664 /etc/elasticsearch/elasticsearch-ca.pem
sudo cp /etc/elasticsearch/elasticsearch-ca.pem /etc/kibana/elasticsearch-ca.pem

## STARTING ELASTIC
sudo systemctl daemon-reload
sudo systemctl start elasticsearch

# Elastic password
printf 'y\nsuperuser\nsuperuser\n' \
| sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -i -u elastic

# kibana password
printf 'y\nkibanauser\nkibanauser\n' \
| sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -i -u kibana_system

sudo echo "y" | sudo /usr/share/kibana/bin/kibana-keystore create
sudo chown root:kibana /usr/share/kibana/bin/kibana-keystore

sudo echo "kibanauser" \
| sudo /usr/share/kibana/bin/kibana-keystore add elasticsearch.password --stdin

sudo echo "elasticsearch.username: 'kibana_system'" | sudo tee -a /etc/kibana/kibana.yml

sudo echo "elasticsearch.password: 'kibanauser'" | sudo tee -a /etc/kibana/kibana.yml

sudo echo "server.port: 5601" \
| sudo tee -a /etc/kibana/kibana.yml

sudo echo "server.host: 0.0.0.0" \
| sudo tee -a /etc/kibana/kibana.yml

sudo echo "server.ssl.enabled: true" \
| sudo tee -a /etc/kibana/kibana.yml

sudo echo "server.ssl.keystore.path: /etc/kibana/http.p12" \
| sudo tee -a /etc/kibana/kibana.yml

sudo echo "server.ssl.keystore.password: 'admin1'" \
| sudo tee -a /etc/kibana/kibana.yml

sudo echo "elasticsearch.hosts: https://${ip4}:9200" \
| sudo tee -a /etc/kibana/kibana.yml

echo "elasticsearch.ssl.certificateAuthorities: /etc/kibana/elasticsearch-ca.pem" \
| sudo tee -a /etc/kibana/kibana.yml

sudo echo "xpack.encryptedSavedObjects.encryptionKey: 'salkdjfhasldfkjhasdlfkjhasdflkasjdfhslkajfhasldkfjhasdlaksdjfh'" \
| sudo tee -a /etc/kibana/kibana.yml

## STARTING KIBANA
sudo systemctl daemon-reload
sudo systemctl start kibana



## NOT NEEDED
#printf '\n' | sudo ./bin/elasticsearch-certutil csr -name kibana-server -dns $ip4
#sudo unzip csr-bundle.zip
#sudo mv ./kibana-server/kibana-server.csr /etc/kibana/kibana-server.csr
#sudo mv ./kibana-server/kibana-server.key /etc/kibana/kibana-server.key
#
#
#echo "server.ssl.certificate: /etc/kibana/kibana-server.crt" \
#| sudo tee -a /etc/kibana/kibana.yml
#
#echo "server.ssl.key: /etc/kibana/kibana-server.key" \
#| sudo tee -a /etc/kibana/kibana.yml
