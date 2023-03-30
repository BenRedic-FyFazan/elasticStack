#!/bin/bash -x

# logs-bf.server
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf.server" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.server.json  

# logs-bf.uc.reports.clerk
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf_uc_reports_clerk" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.uc.reports.clerk

# logs-bf.uc.reports.continuous
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf_uc_reports_continuous" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.uc.reports.continuous

# logs-bf.uc.reports.leeshore
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf_uc_reports_leeshore" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.uc.reports.leeshore

# logs-bf.uc.reports.webcheck
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf_uc_reports_webcheck" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.uc.reports.webcheck

# logs-bf.uc.reports.webuse
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf_uc_reports_webuse" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.uc.reports.webuse
