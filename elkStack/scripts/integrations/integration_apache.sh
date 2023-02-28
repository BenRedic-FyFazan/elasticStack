#!/bin/bash -x

echo "Starting integration_apache.sh"

# Install apache integration
curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X POST "https://localhost:5601/api/fleet/epm/packages/apache/1.8.0" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '{"force": true}'
