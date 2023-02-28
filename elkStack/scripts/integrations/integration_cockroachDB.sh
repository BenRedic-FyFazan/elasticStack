#!/bin/bash -x

echo "Starting integration_cockroachDB.sh"

curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X POST "https://192.168.130.186:5601/api/fleet/epm/packages/cockroachdb/1.1.0" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d \
'{
  "force": true
}'
