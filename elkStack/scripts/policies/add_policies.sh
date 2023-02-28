#!/bin/bash

echo "Starting add_policies.sh"

# apache integration
curl -u elastic:superuser --cacert /home/ubuntu/elasticsearch-ca.pem \
-X POST "https://localhost:5601/api/fleet/package_policies" \
-H "Content-Type: application/json" \
-H "kbn-xsrf: true" \
-d @/home/ubuntu/elkStack_DCSG2003/elkStack/policy/apache/add_integration_apache.json

# haproxy integration
curl -u elastic:superuser --cacert /home/ubuntu/elasticsearch-ca.pem \
-X POST "https://localhost:5601/api/fleet/package_policies" \
-H "Content-Type: application/json" \
-H "kbn-xsrf: true" \
-d @/home/ubuntu/elkStack_DCSG2003/elkStack/policy/haproxy/add_integration_haproxy.json

# cockroachDB integration
curl -u elastic:superuser --cacert /home/ubuntu/elasticsearch-ca.pem \
-X POST "https://localhost:5601/api/fleet/package_policies" \
-H "Content-Type: application/json" \
-H "kbn-xsrf: true" \
-d @/home/ubuntu/elkStack_DCSG2003/elkStack/policy/cockroachDB/add_integration_cockroachDB.json



