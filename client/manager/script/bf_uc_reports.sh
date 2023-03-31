#!/bin/bash -x

# Run this to guarantee that openstack commands can be run
openstack_auth_location="$HOME/elasticStack/client/manager/openstack_auth.txt"
openstack_auth=$(cat "$openstack_auth_location")
source "$openstack_auth"

json=$(uc reports)

# Groups the nested objects in the received JSON by their "type" value then iterates through
grouped_json=$(echo "$json" | jq 'reduce .Reports[] as $item ({}; .[$item.type] += [$item])')
for type in $(echo "$grouped_json" | jq -r 'keys[]'); do

    LOG_FILE="/var/log/bookface/bf_uc_reports_${type}.log"
    objects=$(echo "$grouped_json" | jq --arg type "$type" '.[$type]')

    # Iterates through each object(within the "type" grouped objects)
    # renames "check_time" to "@timestamp", and appends it as a single JSON object
    echo "$objects" | jq -rc '.[] | with_entries(if .key == "check_time" then .key = "report-timestamp" else . end) | @json' | while IFS= read -r object; do
        object=$(echo "$object" | jq -rc 'del(._id, .name, .type) | @json')
        object=$(echo "$object" | jq -rc 'if .vmcount | type == "string" then .vmcount |= fromjson | @json else . | @json end')
        echo "$object" >> "$LOG_FILE"
    done

done
