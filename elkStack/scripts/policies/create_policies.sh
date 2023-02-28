#!/bin/bash

echo "Starting create_policies.sh"

# Apache policy
curl -u elastic:superuser --cacert /home/ubuntu/elasticsearch-ca.pem \
-X POST "https://localhost:5601/api/fleet/agent_policies?sys_monitoring=true" \
-H "Content-Type: application/json" \
-H "kbn-xsrf: true" \
-d @elkStack_DCSG2003/elkStack/policy/apache/create_bookface_apache.json

# Haproxy
curl -u elastic:superuser --cacert /home/ubuntu/elasticsearch-ca.pem \
-X POST "https://localhost:5601/api/fleet/agent_policies?sys_monitoring=true" \
-H "Content-Type: application/json" \
-H "kbn-xsrf: true" \
-d @elkStack_DCSG2003/elkStack/policy/haproxy/create_bookface_haproxy.json

# cockroachDB
curl -u elastic:superuser --cacert /home/ubuntu/elasticsearch-ca.pem \
-X POST "https://localhost:5601/api/fleet/agent_policies?sys_monitoring=true" \
-H "Content-Type: application/json" \
-H "kbn-xsrf: true" \
-d @elkStack_DCSG2003/elkStack/policy/cockroachDB/create_bookface_cockroachDB.json

