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


echo "Uninstalling and reverting changes..."

# Remove CRON jobs
cronjob_1="* * * * * $manager/script/bf_os_servers.sh"
cronjob_2="*/5 * * * * $manager/script/bf_uc_reports.sh"
temp_file=$(mktemp)
crontab -l | grep -v -F "$cronjob_1" | grep -v -F "$cronjob_2" > "$temp_file"
crontab "$temp_file"
rm "$temp_file"

# Remove logrotation
sudo rm -f "${logrotated}bf_os_servers"
sudo rm -f "${logrotated}bf_uc_reports"

# Uninstall filebeat
echo "Uninstalling Filebeat..."
sudo systemctl stop filebeat
sudo systemctl disable filebeat
sudo apt-get remove --purge -y filebeat

echo "Uninstallation and reversion complete."

