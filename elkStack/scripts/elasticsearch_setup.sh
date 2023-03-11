#!/bin/bash -x

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

# elkStack config
sudo rm /etc/elasticsearch/elasticsearch.yml
sudo cp $elkStack/code/elasticSearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

# jvm_max size
sudo cp $elkStack/code/elasticSearch/jvm_heap_size.options /etc/elasticsearch/jvm.options.d/jvm_heap_size.options
