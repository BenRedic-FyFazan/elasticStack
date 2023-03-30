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

# Mappings for bf.uc.reports.clerk
curl -u $api_auth --cacert $ca \
-X PUT "${api_component_template}/bf.map.uc.reports.clerk" \
-H "Content-Type: application/json" \
-d @$component_template/bf.map.uc.reports.clerk

# Mappings for bf.uc.reports.webcheck
curl -u $api_auth --cacert $ca \
-X PUT "${api_component_template}/bf.map.uc.reports.webcheck" \
-H "Content-Type: application/json" \
-d @$component_template/bf.map.uc.reports.webcheck

# Mappings for bf.uc.reports.webuse
curl -u $api_auth --cacert $ca \
-X PUT "${api_component_template}/bf.map.uc.reports.webuse" \
-H "Content-Type: application/json" \
-d @$component_template/bf.map.uc.reports.webuse

# Mappings for bf.uc.reports.continuous
curl -u $api_auth --cacert $ca \
-X PUT "${api_component_template}/bf.map.uc.reports.continuous" \
-H "Content-Type: application/json" \
-d @$component_template/bf.map.uc.reports.continuous

# Mappings for bf.uc.reports.leeshore
curl -u $api_auth --cacert $ca \
-X PUT "${api_component_template}/bf.map.uc.reports.leeshore" \
-H "Content-Type: application/json" \
-d @$component_template/bf.map.uc.reports.leeshore
