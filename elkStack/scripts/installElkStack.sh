#!/bin/bash -x
#### SET PASSWORDS AND USERS, PLEASE CHANGE VALUES IF YOU WANT NON-DEFAULT
export elastic_SU_PW="superuser"
export kibana_U_PW="kibanauser"
#### NO MORE CONFIG FOR USERS AFTER THIS

## VERIFY THAT THIS IS NEEDED
# Openstack API scriot: [NAME]-openrc.sh 
export openstack_auth=/home/ubuntu/DCSG2003_V23_group44-openrc.sh  

######################################## VARIABLES ########################################
## Users, passwords and certificates
# Users
export elastic_SU="elastic"                                     # Default elastic superuser
export kibana_U="kibana_system"                                 # Kibana system user

# Cert passwords
export ca_PW="admin1"                                           # Password for Certificate Authority
export cert_PW="admin1"                                         # Password for SSL/TLS Certificate
export cert_http_PW="admin1"                                    # Password for HTTP certificate

## locations
# Home
export home=$HOME                                               # Home folder

# Repo
export elkStack=$HOME/elasticStack/elkStack                     # "root" of elasticStack host project files
export scripts=$elkStack/scripts                                # Directory for scripts (.sh)
export policy=$elkStack/policy                                  # Directory for policies (JSON formatted)
export index_template=$elkStack/index_template                  # Directory for index templates
export index_lifecycle=$elkStack/index_lifecycle
export ingest_pipeline=$elkStack/ingest_pipeline
export component_template=$elkStack/component_template

# Elasticsearch
export etcElastic=/etc/elasticsearch                            # Elastic configuration files
export usrElastic=/usr/share/elasticsearch                      # Elastic binaries and supporting files

# Kibana
export etcKibana=/etc/kibana                                    # Kibana configuration files
export usrKibana=/usr/share/kibana                              # Kibana binaries and supporting files

## API endpoints
# Kibana
export api_fleet="https://127.0.0.1:5601/api/fleet"

# Elasticsearch
export api_index_template="https://127.0.0.1:9200/_index_template"
export api_index_lifecycle_policy="https://127.0.0.1:9200/_ilm/policy"
export api_component_template="https://127.0.0.1:9200/_component_template"
export api_ingest_pipeline="https://127.0.0.1:9200/_ingest/pipeline"

## various variables
export ip4=$(/sbin/ip -o -4 addr list ens3 | awk '{print $4}' | cut -d/ -f1) # Fetches IP address of ens3
export ip_local="127.0.0.1"                                      # localhost
export api_auth="$elastic_SU:$elastic_SU_PW"                     # API endpoint authentication
export ca=$HOME/elasticStack/elasticsearch-ca.pem           # Certificate authority (generate midways)


######################################## INSTALL ##############################################
# Installing dependencies, setting java runtime environment and pulling git repo
sudo apt-get update && sudo apt-get install -y git ca-certificates curl gnupg lsb-release
sudo apt update && sudo apt install -y net-tools unzip apt-transport-https openjdk-17-jdk
echo 'JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"' | sudo tee -a /etc/environment
source /etc/environment
cd "$HOME" || exit        
sudo git clone https://github.com/BenRedic-FyFazan/elasticStack.git

# Installing elkStack
"$scripts"/elasticsearch_setup.sh
"$scripts"/logstash_setup.sh
"$scripts"/kibana_setup.sh
"$scripts"/filebeat_setup.sh

# Certificates
"$scripts"/certs_setup_pt1.sh
"$scripts"/certs_setup_pt2.sh

## Waits for kibana fleet API endpoint, exits if 5 minutes goes by without response
MAX_WAIT=300
start_time=$(date +%s)
while true; do
  response=$(curl -u $elastic_SU:$elastic_SU_PW --cacert $ca --silent --head --request GET "https://127.0.0.1:5601/api/status")
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

# Installing Integrations
"$scripts"/integration_setup.sh

# Creating policies
"$scripts"/policy/create_policies.sh

# Adding integrations to policies
"$scripts"/policy/add_integrations_to_policy.sh

# Index lifecycle
"$scripts"/index_lifecycle.sh

# Component template
"$scripts"/component_template.sh

# Ingest pipeline
"$scripts"/ingest_pipeline.sh

# Index template
"$scripts"/index_template.sh

# Log completion status so manager knows when install is completed
echo "Installation complete" > /tmp/elk_install_complete.log
