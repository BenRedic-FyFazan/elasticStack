#!/bin/bash -x

# General index lifecycle policy
curl -u $api_auth --cacert $ca \
-X PUT "${api_index_lifecycle_policy}/bf-ilm" \
-H "Content-Type: application/json" \
-d @$index_lifecycle/bf-ilm.json
