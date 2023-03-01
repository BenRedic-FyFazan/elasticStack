#!/bin/bash

echo "Starting create_policies.sh"

# Apache policy
curl -u $api_auth --cacert $ca \
-X POST "${api_fleet}/agent_policies?sys_monitoring=true" \
-H "Content-Type: application/json" \
-H "kbn-xsrf: true" \
-d @$policy/apache/create_bookface_apache.json

# Haproxy
curl -u $api_auth --cacert $ca \
-X POST "${api_fleet}/agent_policies?sys_monitoring=true" \
-H "Content-Type: application/json" \
-H "kbn-xsrf: true" \
-d @$policy/haproxy/create_bookface_haproxy.json

# cockroachDB
curl -u $api_auth --cacert $ca \
-X POST "${api_fleet}/agent_policies?sys_monitoring=true" \
-H "Content-Type: application/json" \
-H "kbn-xsrf: true" \
-d @$policy/cockroachDB/create_bookface_cockroachDB.json

