#!/bin/bash -x

# logs-bf.server
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf.server" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.server.json  

# logs-bf.uc.reports.clerk
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf.uc.reports.clerk" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.uc.reports.clerk

# logs-bf.uc.reports.continuous
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf.uc.reports.continuous" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.uc.reports.continuous

# logs-bf.uc.reports.leeshore
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf.uc.reports.leeshore" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.uc.reports.leeshore

# logs-bf.uc.reports.webcheck
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf.uc.reports.webcheck" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.uc.reports.webcheck

# logs-bf.uc.reports.webuse
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf.uc.reports.webuse" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.uc.reports.webuse

# logs-bf.uc.log
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf.uc.log" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.uc.log

# logs-bf.apache.access
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf.apache.access" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.apache.access

# logs-bf.apache.error
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf.apache.error" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.apache.error
