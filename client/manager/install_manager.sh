#!/bin/bash -x

# Variables
manager="$HOME/elasticStack/client/manager"
vars="$HOME/elasticStack/vars"
elastic_ca="$HOME/elasticStack/vars/elasticsearch-ca.pem"
elastic_ip=$(cat $HOME/elasticStack/vars/elasticsearch_ip.txt)
filebeat_yml="$HOME/elasticStack/vars/filebeat.yml"
search_dir="/"
openstack_auth_location="$HOME/elasticStack/client/manager/openstack_auth.txt"
export logrotated="/etc/logrotate.d/"
export log_loc="/var/log/bookface/"
export log_uc_reports="/var/log/bookface/bf_uc_reports.log"
export log_os_servers="/var/log/bookface/bf_os_servers.log"
bf_os_servers_script="$HOME/elasticStack/client/manager/script/bf_os_servers.sh"
bf_uc_reports_script="$HOME/elasticStack/client/manager/script/bf_uc_reports.sh"

# Installation
echo "Installing nessecary dependencies..."
sudo apt update && sudo apt install -y apt-transport-https
if ! command -v openstack >/dev/null 2>&1; then
  echo "openstack client (openstack) not found, installing..."
  sudo apt update
  sudo apt install -y python3-openstackclient
else
  echo "openstack client (openstack) found, proceeding..."
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq not found, installing..."
  sudo apt-get update
  sudo apt-get install -y jq
else
  echo "jq found, proceeding..."
fi

if ! command -v yq >/dev/null 2>&1; then
  echo "yq not found, installing..."
  sudo snap install yq
else
  echo "yq found, proceeding..."
fi

if ! command -v filebeat >/dev/null 2>&1; then
  echo "filebeat not found, installing..."
  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
  echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
  sudo apt-get update && sudo apt-get install filebeat
  sudo systemctl enable filebeat
else
  echo "filebeat found, proceeding..."
fi

## Finds openstack_rc file and stores it to openstack_auth.txt
echo "Locating openstack_rc file..."
openstack_auth=$(find "$search_dir" -type f -regex '.*DCSG2003_V[0-9]+_group[0-9]+-openrc.sh' 2>/dev/null | head -n 1)
echo "$openstack_auth" > "$openstack_auth_location" 

if [ -z "$openstack_auth" ]; then 
    echo "No openstack_rc file found. aborting installation"
    exit 1
else 
    echo "Openstack_rc file found at: '$openstack_auth'"
    echo "Verifying connection..."

    ## Checks for token issues. exit status 0 = success. 
    openstack_auth=$(cat "$openstack_auth_location")
    source "$openstack_auth"
    if openstack token issue >/dev/null 2>&1; then
        echo "Successfully connected to OpenStack."
    else
        echo "Failed to connect to OpenStack. Aborting installation."
        exit 1
    fi
    
    echo "Proceeding with installation"
fi 

## Making the logfiles
sudo mkdir $log_loc
sudo chown root:ubuntu $log_loc
sudo chmod 664 $log_loc
sudo chmod +x $log_loc
sudo touch $log_uc_reports
sudo chown root:ubuntu $log_uc_reports 
sudo chmod 664 $log_uc_reports
sudo touch $log_os_servers
sudo chown root:ubuntu $log_os_servers
sudo chmod 664 $log_os_servers

## Adding logrotation
sudo cp $manager/logrotate.d/* $logrotated

## Adding to crontab
cronjob_1="* * * * * $manager/script/bf_os_servers.sh"
cronjob_2="*/5 * * * * $manager/script/bf_uc_reports.sh"
temp_file=$(mktemp)
crontab -l > "$temp_file"
echo "$cronjob_1" >> "$temp_file"
echo "$cronjob_2" >> "$temp_file"
crontab "$temp_file"
rm "$temp_file"

touch $filebeat_yml
cp $manager/code/filebeat.yml $filebeat_yml
yq eval -i ".output.elasticsearch.hosts[0] = \"https://$elastic_ip:9200\"" $filebeat_yml
sudo rm /etc/filebeat/filebeat.yml
sudo cp $filebeat_yml /etc/filebeat.yml

sudo systemctl restart filebeat.service
