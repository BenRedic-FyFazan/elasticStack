#!/bin/bash -x

echo "Starting integration_base.sh"

# Installing system integration
curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X POST "https://localhost:5601/api/fleet/epm/packages/system/1.24.3" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '{"force": true}'

# Installing agent integration
curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X POST "https://localhost:5601/api/fleet/epm/packages/elastic_agent/1.5.1" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '{"force": true}'
