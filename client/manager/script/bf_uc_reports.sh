#!/bin/bash -x

#Run this to guarantee that openstack commands can be run
openstack_auth_location="$HOME/elasticStack/client/manager/openstack_auth.txt"
openstack_auth=$(cat "$openstack_auth_location")
source "$openstack_auth"

# Set the log file path
LOG_FILE="/var/log/bookface/bf_uc_reports.log"

# Fetch the JSON file
json=$(uc reports)

# Generate a timestamp
timestamp=$(date +"%Y-%m-%dT%H:%M:%S.%3N%z")

# Read the JSON file
content=$(echo $json)

# Rename 'uc-api-version' to 'api-version'
content=$(echo $content | jq 'with_entries(if .key == "uc-api-version" then .key = "api-version" else . end)')

# Group the objects by their "type" value and create an array for each type
grouped_json=$(echo $content | jq 'reduce .Reports[] as $item ({}; .[$item.type] += [$item | del(.type)])')

# Create a new JSON object with the desired structure
final_json=$(echo $grouped_json | jq --arg ts "$timestamp" --argjson content "$content" '. as $grouped | { "api-version": $content["api-version"], "Reports": $grouped } + { "@timestamp": $ts }')

# Write the updated JSON object to a file
echo $final_json >> "$LOG_FILE"
