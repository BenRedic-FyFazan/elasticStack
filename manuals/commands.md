# Testing SSL/TLS

``
sudo openssl s_client -connect [IP]:[port] -CAfile [Path to ...ca.pem]
``

For example:
``
sudo openssl s_client -connect 10.212.175.148:9200 -CAfile /home/ubuntu/instance/elasticsearch-ca.pem
``

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
"https://localhost:9200/_ingest/pipeline/logs-bookface-apache.error" \
-H 'Content-Type: application/json' \
-u elastic:superuser \
--cacert elasticsearch-ca.pem \
-d @logs_bookface_apache_error.json
  
(We're in the same folder as the ca.pem here)
``



## INSTALLING AN INTEGRATION TO ELASTIC Maybe?
curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X POST "https://192.168.130.186:5601/api/fleet/epm/packages/apache/1.8.0" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d \
'{
  "force": true
}'


curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X POST "https://localhost:5601/api/fleet/epm/packages/system/1.24.3" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '{"force": true}'

curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X POST "https://localhost:5601/api/fleet/epm/packages/elastic_agent/1.5.1" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '{"force": true}'
