#!/bin/bash -x

echo "Starting integration_haproxy.sh"

curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X POST "https://localhost:5601/api/fleet/epm/packages/haproxy/1.5.0" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d \
'{
  "force": true
}'
