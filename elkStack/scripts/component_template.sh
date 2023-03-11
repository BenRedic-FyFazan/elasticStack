#!/bin/bash -x

# Mappings for @timestamp and message
curl -u $api_auth --cacert $ca \
-X PUT "${api_component_template}/bf.map.time_msg" \
-H "Content-Type: application/json" \
-d @$component_template/bf.map.time_msg.json

# Index Lifecycle policy settings
curl -u $api_auth --cacert $ca \
-X PUT "${api_component_template}/bf.set.ilm" \
-H "Content-Type: application/json" \
-d @$component_template/bf.set.ilm.json

# Mappings for bf.server
curl -u $api_auth --cacert $ca \
-X PUT "${api_component_template}/bf.map.server" \
-H "Content-Type: application/json" \
-d @$component_template/bf.map.server.json

