#!/bin/bash -x

# Variables
manager="$HOME/elasticStack/client/manager"
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
sudo apt-get update -y && sudo apt-get install -y jq python3-openstackclient

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
