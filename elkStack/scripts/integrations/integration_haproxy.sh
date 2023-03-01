#!/bin/bash -x

echo "Starting integration_haproxy.sh"

curl -u $api_auth --cacert $ca \
-X POST "${api_fleet)/epm/packages/haproxy/1.5.0" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d \
'{
  "force": true
}'
