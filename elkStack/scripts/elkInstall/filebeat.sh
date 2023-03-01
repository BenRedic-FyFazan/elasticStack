#!/bin/bash -x
# Filebeat install and config
## Might not be functional as it isn't really used atm
sudo apt-get install filebeat -y
sudo rm /etc/filebeat/filebeat.yml
sudo cp $elkStack/code/filebeat/filebeat.yml /etc/filebeat/filebeat.yml
sudo filebeat modules enable system

## loading filebeat index
sudo filebeat setup --index-managementsudo filebeat setup \
 --index-management -E output.logstash.enabled=false \
-E 'output.elasticsearch.hosts=["0.0.0.0:9200"]'
sudo systemctl daemon-reload
#sudo systemctl enable filebeat

