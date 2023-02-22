# Pipeline related:

### downloading a pipeline from elasticsearch/kibana:

``
curl -X GET \
"https://[ELASTICSEARCH IP]:9200/_ingest/pipeline/{[PIPELINE IP]}" \
-H 'Content-Type: application/json' \
-o pipeline_config.json \
-u [USERNAME]:[PASSWORD] \
--cacert [ABSOLUTE PATH TO CA.PEM]
``

For example:
``
curl -X GET \
"https://192.168.131.133:9200/_ingest/pipeline/{logs-apache.access-1.8.0-modified}" \
 -H 'Content-Type: application/json' \
 -o pipeline_config.json \
 -u elastic:superuser \
 --cacert elasticsearch-ca.pem 
``
