#!/bin/bash -x
#### SET PASSWORDS AND USERS, PLEASE CHANGE VALUES IF YOU WANT NON-DEFAULT
export elastic_SU_PW="superuser"
export kibana_U_PW="kibanauser"
#### NO MORE CONFIG FOR USERS AFTER THIS

# Users
export elastic_SU="elastic"                                            # Default elastic superuser
export kibana_U="kibana_system"                                        # Kibana system user

# Cert passwords
export ca_PW="admin1"                                                  # Password for Certificate Authority
export cert_PW="admin1"                                                # Password for SSL/TLS Certificate
export cert_http_PW="admin1"                                           # Password for HTTP certificate

# Installing dependencies, setting java runtime environment and pulling git repo
sudo apt-get update && sudo apt-get install -y git ca-certificates curl gnupg lsb-release 
sudo apt update && sudo apt install -y net-tools unzip apt-transport-https openjdk-17-jdk
echo 'JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"' | sudo tee -a /etc/environment
source /etc/environment
cd /home/ubuntu/
sudo git clone https://github.com/BenRedic-FyFazan/elkStack_DCSG2003.git

# various variables
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

export api_auth="$elastic_SU:$elastic_SU_PW"                    # API endpoint authentication

# API endpoints
export api_fleet="https://localhost:5601/api/fleet"

# Installing elkStack
$scripts/elkInstall/elasticsearch.sh
$scripts/elkInstall/logstash.sh
$scripts/elkInstall/kibana.sh
$scripts/elkInstall/filebeat.sh

# Certificates
$scripts/certificates/elkCerts_setup_pt1.sh
$scripts/certificates/elkCerts_setup_pt2.sh

## Waits for kibana fleet API endpoint, exits if 5 minutes goes by without response
MAX_WAIT=300
start_time=$(date +%s)
while true; do
  response=$(curl -u $elastic_SU:$elastic_SU_PW --cacert $ca --silent --head --request GET "https://localhost:5601/api/status")
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
$scripts/integrations/integration_base.sh
$scripts/integrations/integration_apache.sh
$scripts/integrations/integration_cockroachDB.sh
$scripts/integrations/integration_memcached.sh
$scripts/integrations/integration_haproxy.sh

# Creating policies
$scripts/policy/create_policies.sh

# Adding integrations to policies
$scripts/policy/add_integrations_to_policy.sh
