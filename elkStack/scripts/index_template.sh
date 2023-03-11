#!/bin/bash -x

# logs-bf.server
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_template}/logs-bf.server" \
-H "Content-Type: application/json" \
-d @$index_template/logs-bf.server.json  
