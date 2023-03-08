#!/bin/bash -x

export ca=/home/ubuntu/elasticsearch-ca.pem
export elastic_SU_PW="superuser"
export kibana_U_PW="kibanauser"
export elastic_SU="elastic"                                            # Default elastic superuser
export kibana_U="kibana_system"    
export ca_PW="admin1"                                                  # Password for Certificate Authority
export cert_PW="admin1"                                                # Password for SSL/TLS Certificate
export cert_http_PW="admin1"   
export ip4=$(/sbin/ip -o -4 addr list ens3 | awk '{print $4}' | cut -d/ -f1) # Fetches IP address of ens3
export ip_local="127.0.0.1"                                     # localhost
export home=/home/ubuntu                                        # Home folder
export elkStack=/home/ubuntu/elkStack_DCSG2003/elkStack         # "root" of project
export ca=/home/ubuntu/elkStack_DCSG2003/elasticsearch-ca.pem   # Certificate authority (generate midways)
export etcElastic=/etc/elasticsearch                            # Elastic configuration files
export etcKibana=/etc/kibana                                    # Kibana configuration files
export usrElastic=/usr/share/elasticsearch                      # Elastic binaries and supporting files
export usrKibana=/usr/share/kibana                              # Kibana binaries and supporting files
export scripts=/home/ubuntu/elkStack_DCSG2003/elkStack/scripts  # Directory for scripts (.sh)
export policy=/home/ubuntu/elkStack_DCSG2003/elkStack/policy    # Directory for policies (JSON formatted)
export index_template=/home/ubuntu/elkStack_DCSG2003/elkStack/index_template # Directory for index templates

export api_auth="$elastic_SU:$elastic_SU_PW"                    # API endpoint authentication

# API endpoints

export api_fleet="https://127.0.0.1:5601/api/fleet"
export api_index="https://127.0.0.1:9200/_index_template"
export api="https://127.0.0.1:9200"


# Index lifecycle
curl -u $api_auth --cacert $ca \
-X PUT "${api}/_ilm/policy/bf-ilm" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' 
-d @$elkStack/index_lifecycle/bf-ilm.json

# Component templates
curl -u $api_auth --cacert $ca \
-X PUT "${api}/_component_template/bf.map.server" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' 
-d @$elkStack/component_template/bf.map.server.json

curl -u $api_auth --cacert $ca \
-X PUT "${api}/_component_template/bf.map.time_msg" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json'
-d @$elkStack/component_template/bf.map.time_msg.json

curl -u $api_auth --cacert $ca \
-X PUT "${api}/_component_template/bf.set.ilm" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json'
-d @$elkStack/component_template/bf.set.ilm.json

# ingest pipeline
curl -u $api_auth --cacert $ca \
-X PUT "${api}/_ingest/pipeline/logs-bf.servers" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json'
-d @$elkStack/ingest_pipeline/logs-bf.servers.json

# Index template
curl -u $api_auth --cacert $ca \
-X PUT "${api}/_index_template/logs-bookface.server" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json'
-d @$elkStack/index_template/logs-bookface.server.json

