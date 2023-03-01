#!/bin/bash -x

echo "Starting integration_apache.sh"

# Install apache integration
curl -u $api_auth --cacert $ca \
-X POST "${api_fleet}/epm/packages/apache/1.8.0" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '{"force": true}'
