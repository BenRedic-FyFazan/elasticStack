#!/bin/bash -x

# Variables
keypairName="Manager-ssh-keypair"
ssh_pub="~/.ssh/id_rsa.pub"
vmName="elasticStack"
vmImage="db1bc18e-81e3-477e-9067-eecaa459ec33"      #Ubuntu Server 22.04 LTS (Jammy Jellyfish) amd54
vmFlavor="4b570035-f1bb-4fc4-bd39-30b09dd9e661"     #gx3.4c4r
elkInstallScript="$HOME/elasticStack/install.sh"

# Need to create a keypair (the others are connected to the openstack users)
openstack keypair create --public-key $ssh_pub $keypairName

# Temp file for installation script
elkInstallTemp=$(mktemp)
cp "$elkInstallScript" "$elkInstallTemp"

# Creating the instance in openstack
openstack server create \
  --image "$vmImage" \
  --flavor "$vmFlavor" \
  --key-name "$keypairName" \
  --user-data "$elkInstallTemp" \
  "$vmName"

# Cleanup
rm "$elkInstallTemp"

while [[ $(openstack server show "$vmName" -c status -f value) != "ACTIVE" ]]; do
  sleep 5
done

# Fetch ip-address of the elasticSearch server and store it to file
ip_address=$(openstack server show "$vmName" -c addresses -f value | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
echo "$ip_address" > $HOME/elasticStack/ip_address.txt
echo "Instance '$vmName' created with IP address: $ip_address"
