#!/bin/bash -x

# Mappings for @timestamp and message
curl -u $api_auth --cacert $ca \
-X PUT "${api_ingest_pipeline}/bf.server" \
-H "Content-Type: application/json" \
-d @$ingest_pipeline/bf.server.json
