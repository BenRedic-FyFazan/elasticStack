#!/bin/bash
#Run this to gurarantee that openstack commands can be run
source /home/ubuntu/DCSG2003_V23_group44-openrc.sh;
# Set the log file path
LOG_FILE="/var/log/bookface/openstack_servers.log"

# Run the OpenStack CLI command and save the output as JSON
OUTPUT=$(openstack server list --long --format json)

# Get the current timestamp
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Parse the JSON output and extract the server name, IP address, and status
SERVERS=$(echo "$OUTPUT" | jq -r 'map({name: .Name, ip: .Networks, status: .Status}) | @json')

# Creates the log entry
#LOG_ENTRY=$(echo "{\"@timestamp\": \"$TIMESTAMP\", \"server\": $SERVERS}")
LOG_ENTRY=$(echo "{\"@timestamp\": \"$TIMESTAMP\", \"bf\": {\"server\": $SERVERS}}")

# Write the log entry to the log file
echo "$LOG_ENTRY" >> "$LOG_FILE"
