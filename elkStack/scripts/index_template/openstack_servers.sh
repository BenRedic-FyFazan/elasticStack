#!/bin/bash -x

curl -u $api_auth --cacert $ca \
-X PUT "${api_index}/openstack_servers" \
-H "Content-Type: application/json" \
-d @$index_template/openstack_servers_template.json  
