#!/bin/bash -x

echo "Starting integration_cockroachDB.sh"

curl -u $api_auth --cacert $ca \
-X POST "${api_fleet}/epm/packages/cockroachdb/1.1.0" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d \
'{
  "force": true
}'
