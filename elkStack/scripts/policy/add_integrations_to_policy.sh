#!/bin/bash

echo "Starting add_policies.sh"

# apache integration
curl -u $api_auth --cacert $ca \
-X POST "${api_fleet}/package_policies" \
-H "Content-Type: application/json" \
-H "kbn-xsrf: true" \
-d @$policy/apache/add_integration_apache.json

# haproxy integration
curl -u $api_auth --cacert $ca \
-X POST "${api_fleet}/package_policies" \
-H "Content-Type: application/json" \
-H "kbn-xsrf: true" \
-d @$policy/haproxy/add_integration_haproxy.json

# cockroachDB integration
curl -u $api_auth --cacert $ca \
-X POST "${api_fleet}/package_policies" \
-H "Content-Type: application/json" \
-H "kbn-xsrf: true" \
-d @$policy/cockroachDB/add_integration_cockroachDB.json



