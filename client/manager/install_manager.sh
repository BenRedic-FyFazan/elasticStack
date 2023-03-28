#!/bin/bash -x

## Finds openstack_rc file and stores it to openstack_auth.txt
search_dir="/"
openstack_auth_location="$HOME/elasticStack/client/manager/openstack_auth.txt"
openstack_auth=$(find "$search_dir" -type f -regex '.*DCSG2003_V[0-9]+_group[0-9]+-openrc.sh' 2>/dev/null | head -n 1)
echo "$openstack_auth" > "$openstack_auth_location" 

if [ -z "$openstack_auth" ]; then 
    echo "No openstack_rc file found. aborting installation"
    exit
else 
    echo "Openstack_rc file found at:"
    echo "$openstack_auth"
    echo "Proceeding with installation"
fi 

export logrotated="/etc/logrotate.d/"
export log_loc="/var/log/bookface/"


