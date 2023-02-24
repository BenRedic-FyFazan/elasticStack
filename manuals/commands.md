# Pipeline related:

### downloading a pipeline from elasticsearch/kibana:
We're using jq to make the json files more readable.


``
curl -X GET \
"https://[IP TO ELASTICSEARCH]:9200/_ingest/pipeline/[PIPELINE ID]" \
-H 'Content-Type: application/json' \
-u [USERNAME]:[PASSWORD] \
--cacert [ABSOLUTE PATH TO CA.PEM] \
| jq '.' > [FILENAME].json
``

For example:
``
curl -X GET \
"https://192.168.131.133:9200/_ingest/pipeline/logs-bookface-apache.error" \
 -H 'Content-Type: application/json' \
 -u elastic:superuser \
 --cacert elasticsearch-ca.pem \
 | jq '.' > logs_bookface_apache_error.json
 
 (We're in the same folder as the ca.pem here)
``


### Importing a pipeline from a file:
Before running the command make sure the JSON is formatted correctly according to https://www.elastic.co/guide/en/elasticsearch/reference/current/put-pipeline-api.html
When exporting the pipeline as above the file might have an extra line at the top before the "description" tag that needs to be removed (in addition to the unessecary braces).

``
curl -X PUT \
 "http://[ELASTICSEARCH IP]:9200/_ingest/pipeline/[PIPELINE ID]" \
 -H "Content-Type: application/json" \
 -d @[ABSOLUTE PATH TO PIPELINE.json]

``

For example:

``
curl -X PUT \
"https://localhost:9200/_ingest/pipeline/logs-apache.access-bookface" \
-H 'Content-Type: application/json' \
-u elastic:superuser \
--cacert elasticsearch-ca.pem \
-d @pipeline.json
  
(We're in the same folder as the ca.pem here)
``



