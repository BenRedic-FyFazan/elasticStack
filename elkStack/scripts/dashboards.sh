#!/bin/bash -x

# Bookface example
curl -u $api_auth --cacert $ca \
-X POST "${api_saved_objects_import}?overwrite=true" \
-H "kbn-xsrf: true" \
--form file=@$dashboards/bf-example.ndjson

