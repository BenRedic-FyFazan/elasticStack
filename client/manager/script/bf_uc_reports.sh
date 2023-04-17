#!/bin/bash -x

LOG_RAW="/var/log/bookface/bf_uc_reports_raw.log"

# Run this to guarantee that openstack commands can be run
openstack_auth_location="$HOME/elasticStack/client/manager/openstack_auth.txt"
openstack_auth=$(cat "$openstack_auth_location")
source "$openstack_auth"

json=$(uc reports)
echo "$json" >> "$LOG_RAW"

# Groups the nested objects in the received JSON by their "type" value then iterates through
grouped_json=$(echo "$json" | jq 'reduce .Reports[] as $item ({}; .[$item.type] += [$item])')
for type in $(echo "$grouped_json" | jq -r 'keys[]'); do

    LOG_FILE="/var/log/bookface/bf_uc_reports_${type}.log"
    objects=$(echo "$grouped_json" | jq --arg type "$type" '.[$type]')

    # Iterates through each object(within the "type" grouped objects)
    echo "$objects" | jq -rc '.[] | @json' | while IFS= read -r object; do
        report_timestamp=$(echo "$object" | jq -rc '.check_time')
        object=$(echo "$object" | jq -rc 'del(._id, .name, .type, .check_time) | @json')

        if [[ "$type" == "clerk" ]]; then
            # Removes the fields with '_' in the name convention (ex: 'gx3_4c4r') and converts string values to numbers
            object=$(echo "$object" | jq -rc 'if .vmcount | type == "string" then .vmcount |= (fromjson | with_entries(select(.key | test("^[^_]*$")) | .value |= tonumber)) | @json else .vmcount |= (with_entries(select(.key | test("^[^_]*$")) | .value |= tonumber)) | @json end')

            # Creates a new field for the current balance, then extracts the value from result and finally removes result.
            object=$(echo "$object" | jq -rc '.balance = 0 | .balance = ( .result | match("New balance is ([0-9.]+)"; "g").captures[0].string | tonumber ) | del(.result)')

            # Creates the fields total_RAM and total_CPU and calculates their values based on the VMcount fields.
            total_RAM=$(echo "$object" | jq -rc '.vmcount | to_entries | map((.key | match("\\d+(?=r)"; "g").string | tonumber) * .value) | add')
            total_CPU=$(echo "$object" | jq -rc '.vmcount | to_entries | map((.key | match("\\d+(?=c)"; "g").string | tonumber) * .value) | add')
            object=$(echo "$object" | jq -rc --argjson total_RAM "$total_RAM" --argjson total_CPU "$total_CPU" '. + {total_RAM: $total_RAM, total_CPU: $total_CPU}')

        fi

        # Wrap the object in another object with the key ('bf.uc.reports.{type}') and append timestamp
        object=$(echo "$object" | jq -rc --arg type "bf.uc.reports.$type" '{ ($type): . }')
        object=$(echo "$object" | jq -rc --arg rt "$report_timestamp" '. + {"report-timestamp": ($rt | tonumber)}')

        echo "$object" >> "$LOG_FILE"
    done

done
