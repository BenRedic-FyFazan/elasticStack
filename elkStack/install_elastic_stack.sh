#!/bin/bash -x

# Variables
keypairName="Manager-ssh-keypair"
ssh_pub="~/.ssh/id_rsa.pub"
ssh_key="~/.ssh/id_rsa"
ssh_options="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
vmName="elasticStack"
vmImage="db1bc18e-81e3-477e-9067-eecaa459ec33"      #Ubuntu Server 22.04 LTS (Jammy Jellyfish) amd54
vmFlavor="4b570035-f1bb-4fc4-bd39-30b09dd9e661"     #gx3.4c4r
elkInstallScript="$HOME/elasticStack/elkStack/scripts/installElkStack.sh"

# openstack client
if ! command -v openstack >/dev/null 2>&1; then
  echo "openstack client (openstack) not found, installing..."
  sudo apt update
  sudo apt install -y python3-openstackclient
fi

# Netcat
if ! command -v nc >/dev/null 2>&1; then
  echo "Netcat (nc) not found, installing..."
  sudo apt-get update
  sudo apt-get install -y netcat
fi 

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
echo "$ip_address" > $HOME/elasticStack/vars/elasticsearch_ip.txt
echo "Instance '$vmName' created with IP address: $ip_address"
cp $HOME/elasticStack/vars/elasticsearch_ip.txt $HOME/elasticStack/client/UClog/elasticsearch_ip.txt

# Checks if SSH service is available 
while ! nc -z -v -w5 "$ip_address" 22; do
  sleep 5
done

# SSH
while true; do
  scp $ssh_options -i "$ssh_key" "ubuntu@$ip_address:/tmp/elk_install_complete.log" "elk_install_complete.log" >/dev/null 2>&1
  if [ $? -eq 0 ] && grep -q "Installation complete" "elk_install_complete.log"; then
    echo "Elasticsearch installation complete"
    break
  else
    sleep 10
  fi
done

scp $ssh_options -i "$ssh_key" "ubuntu@$ip_address:/elasticsearch-ca.pem" "$HOME/elasticStack/vars" >/dev/null 2>&1
cp $HOME/elasticStack/vars/elasticsearch-ca.pem $HOME/elasticStack/client/UClog/elasticsearch-ca.pem

# Cleanup
rm "elk_install_complete.log"
echo "Instance '$vmName' created with IP address: $ip_address"
