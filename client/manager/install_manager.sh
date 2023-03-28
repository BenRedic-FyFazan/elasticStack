#!/bin/bash -x

echo "Installing nessecary dependencies..."
sudo apt-get update && sudo apt-get install jq python3-openstackclient

## Finds openstack_rc file and stores it to openstack_auth.txt
echo "Locating openstack_rc file..."
search_dir="/"
openstack_auth_location="$HOME/elasticStack/client/manager/openstack_auth.txt"
openstack_auth=$(find "$search_dir" -type f -regex '.*DCSG2003_V[0-9]+_group[0-9]+-openrc.sh' 2>/dev/null | head -n 1)
echo "$openstack_auth" > "$openstack_auth_location" 

if [ -z "$openstack_auth" ]; then 
    echo "No openstack_rc file found. aborting installation"
    exit 1
else 
    echo "Openstack_rc file found at:"
    echo "$openstack_auth"
    echo "Verifying connection to openstack..."

    ## Checks for token issues. exit status 0 = success. 
    openstack_auth=$(cat "$openstack_auth_location")
    source "$openstack_auth"
    if openstack token issue >/dev/null 2>&1; then
        echo "Successfully connected to OpenStack."
        echo "Proceeding with installation."
    else
        echo "Failed to connect to OpenStack. Aborting installation."
        exit 1
    fi
    
    echo "Proceeding with installation"
fi 

export logrotated="/etc/logrotate.d/"
export log_loc="/var/log/bookface/"


