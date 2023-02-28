#!/bin/bash -x

sudo apt-get update -y
sudo apt-get install -y \
git \ 
ca-certificates \ 
curl \ 
gnupg \ 
lsb-release 

sudo apt install net-tools 
sudo apt install unzip

## INSTALLATION
# Installing https transport and java runtime environment
sudo apt update
sudo apt install apt-transport-https
sudo apt install openjdk-17-jdk

# Setting java runtime environment
echo 'JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"' | sudo tee -a /etc/environment
source /etc/environment

# getting elasticSearch key
wget -qO \
- https://artifacts.elastic.co/GPG-KEY-elasticsearch \
| sudo gpg --dearmor \
-o /usr/share/keyrings/elasticsearch-keyring.gpg 

# Setting the key
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" \
| sudo tee /etc/apt/sources.list.d/elastic-8.x.list

# Installing elasticSearch
sudo apt-get update && sudo apt-get install elasticsearch -y
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch


## CONFIGURATION

# Pulling git repo and navigating to home
cd /home/ubuntu/
sudo git clone https://github.com/BenRedic-FyFazan/elkStack_DCSG2003.git

# elkStack config
cd ./elkStack_DCSG2003/elkStack/
sudo rm /etc/elasticsearch/elasticsearch.yml
sudo cp code/elasticSearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
# jvm_max size
sudo cp code/elasticSearch/jvm_heap_size.options /etc/elasticsearch/jvm.options.d/jvm_heap_size.options
#sudo systemctl restart elasticsearch

# Logstash install
sudo apt-get install logstash -y
sudo systemctl daemon-reload
sudo systemctl enable logstash

# Kibana install
sudo apt-get install kibana -y 
sudo systemctl daemon-reload
sudo systemctl enable kibana

# Filebeat install and config
## Might not be functional as it isn't really used atm
sudo apt-get install filebeat -y
cd /home/ubuntu/elkStack_DCSG2003/elkStack/
sudo rm /etc/filebeat/filebeat.yml
sudo cp code/filebeat/filebeat.yml /etc/filebeat/filebeat.yml
sudo filebeat modules enable system

## loading filebeat index
sudo filebeat setup --index-managementsudo filebeat setup \
 --index-management -E output.logstash.enabled=false \
-E 'output.elasticsearch.hosts=["0.0.0.0:9200"]'
sudo systemctl daemon-reload
sudo systemctl enable filebeat

# Certificates
./scripts/certificates/elkCerts_setup_pt1.sh
./scripts/certificates/elkCerts_setup_pt2.sh

# Integrations
cd /home/ubuntu

## Wait for server to be up
MAX_WAIT=300
start_time=$(date +%s)
while true; do
  response=$(curl -u elastic2:superuser --cacert elasticsearch-ca.pem --silent --head --request GET "https://localhost:5601/api/status")
  if [[ $response == *"200 OK"* ]]; then
    break
  fi
  current_time=$(date +%s)
  if (( current_time - start_time >= MAX_WAIT )); then
    echo "Timeout waiting for server to become available"
    exit 1
  fi
  sleep 10
done

./elkStack_DCSG2003/elkStack/scripts/integrations/integration_base.sh
./elkStack_DCSG2003/elkStack/scripts/integrations/integration_apache.sh
./elkStack_DCSG2003/elkStack/scripts/integrations/integration_cockroachDB.sh
./elkStack_DCSG2003/elkStack/scripts/integrations/integration_memcached.sh
./elkStack_DCSG2003/elkStack/scripts/integrations/integration_haproxy.sh
