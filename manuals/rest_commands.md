#Ingest Pipeline
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
"https://localhost:9200/_ingest/pipeline/logs-apache.access-1.8.0 " \
 -H 'Content-Type: application/json' \
 -u elastic:superuser \
 --cacert elasticsearch-ca.pem \
 | jq '.' > logs_apache_access.json
 
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
https://localhost:9200/_ingest/pipeline/logs-bookface-apache.access" \
-H 'Content-Type: application/json' \
-u elastic:superuser \
--cacert elasticsearch-ca.pem \
-d @logs_bookface_apache_error.json
  
(We're in the same folder as the ca.pem here)
``



### Updating a pipeline
THIS REPLACES ALL THE CONTENTS OF THE PIPELINE INSTEAD OF JUST UPDATING THE FIELD
``
curl -X PUT \
"https://localhost:9200/_ingest/pipeline/logs-apache.access-1.8.0" \
-H 'Content-Type: application/json' \
-u elastic:superuser \
--cacert elasticsearch-ca.pem \
-d '{ 
    "processors" : [
    { 
        "grok": {
          "field": "event.original",
          "patterns": [
                "%{IPORHOST:source.address} - %{DATA:user.name} \\[%{HTTPDATE:apache.access.time}\\] \"-\" %{NUMBER:http.response.status_code:long} -"
          ],
          "ignore_missing": true,
          "pattern_definitions": {
            "ADDRESS_LIST": "(%{IP})(\"?,?\\s*(%{IP}))*"
          }
        }
      }
   ]
}'
``




## Integrations:
### List available integrations + status of integrations:
(We use jq to put the output in a file and make it easier to read for humans)

``
curl -u [User]:[Password] --cacert [Certificate Authority] \
-X GET "[KibanaUrl]/api/fleet/epm/packages" -H 'kbn-xsrf: true' \
| jq '.' > integrationList.json
``

For example:
``
curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X GET "https://192.168.130.186:5601/api/fleet/epm/packages" -H 'kbn-xsrf: true' \
| jq '.' > integrationList.json
``

curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X GET "https://localhost:5601/api/fleet/epm/packages" -H 'kbn-xsrf: true' \
| jq '.' > integrationList.json

### Installing an integration
``
curl -u [User]:[Password] --cacert [Certificate Authority] \
-X POST "[KibanaUrl]/api/fleet/epm/packages/[Package Name]/[Package Version]" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d \
'{
  "force": true
}'
``

For example:
``
curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X POST "https://192.168.130.186:5601/api/fleet/epm/packages/cockroachdb/1.1.0" \
-H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d \
'{
  "force": true
}'
``

# Policies 

## List policy

### Listing all policies
To list all available policies we run the following:
``
curl -u [User]:[Password] --cacert [Certificate Authority] \
-X GET "[KibanaUrl]/api/fleet/epm/packages" -H 'kbn-xsrf: true' \
| jq '.' > integrationList.json
``

For example:
``
curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X GET "https://localhost:5601/api/fleet/agent_policies" -H 'kbn-xsrf: true' \
| jq '.' > policyList.json
``

### Listing a specific policy
We can get a specific policy via the following command:

``
curl -u [User]:[Password] --cacert [Certificate Authority] \
-X GET "[KibanaURL]/api/fleet/agent_policies/[Agent Policy ID]" \
-H 'kbn-xsrf: true' \
| jq '.' > policy.json
``

for example: 
``
curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X GET "https://localhost:5601/api/fleet/agent_policies/cfb41000-b77e-11ed-a59e-95a4167c990d" \
-H 'kbn-xsrf: true' \
| jq '.' > policy.json
``

## Creating and updating policies

### Creating a policy:

For example:
``
curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X POST "https://localhost:5601/api/fleet/agent_policies?sys_monitoring=true" \
-H "Content-Type: application/json" \
-H "kbn-xsrf: true" \
-d @elkStack_DCSG2003/elkStack/policy/create_bookface_policies.json
``

### Updating a policy with a new integration:
The 'add_integration_apache.json' contains the nessecary configuration files for the addition.

For example:
``
curl -u elastic:superuser --cacert elasticsearch-ca.pem \
-X POST "https://localhost:5601/api/fleet/package_policies" \
-H "Content-Type: application/json" \
-H "kbn-xsrf: true" \
-d @elkStack_DCSG2003/elkStack/policy/apache/add_integration_apache.json
``

# CREATE POLICY
POST kbn:/api/fleet/agent_policies?sys_monitoring=true
{
  "name": "bookface-apache",
  "description": "",
  "namespace": "default",
  "monitoring_enabled": [
    "logs",
    "metrics"
  ]
}


# ADD APACHE TO POLICY



# CREATE INDEX TEMPLATE

curl -u elastic:superuser --cacert /home/ubuntu/elasticsearch-ca.pem \
-X PUT "https://127.0.0.1:9200/_index_template/logs-bookface.server" \
-H "Content-Type: application/json" \
-d @/home/ubuntu/testing/logs-bookface.server.json


# CREATE DATA STREAM

curl -u elastic:superuser --cacert /home/ubuntu/elasticsearch-ca.pem \
-X PUT "https://127.0.0.1:9200/_data_stream/openstack_servers" \
-H "Content-Type: application/json" \
-d '
{
  "template": {
    "name": "openstack_servers"
  }
}'

# CREATING/Posting to datastream
curl -u elastic:superuser --cacert /home/ubuntu/elasticsearch-ca.pem \
-X POST "https://127.0.0.1:9200/logs-bookface.server/_doc" \
-H "Content-Type: application/json" \
-d @/home/ubuntu/testing/testlog.log


curl -u elastic:superuser --cacert /home/ubuntu/elasticsearch-ca.pem \
-X PUT "https://127.0.0.1:9200/_data_stream/logs-bookface.server" 



PUT _ingest/pipeline/logs-bf.server
{
  "description": "Pipeline for the bf.server logs",
  "processors": [
    {
      "foreach": {
        "field": "bf.servers",
        "processor": {
          "set": {
            "description": "Parses the bf.servers object array. Creates a field for every VM name and appends the status and hostname fields to it.",
            "field": "bf.server.{{_ingest._value.name}}",
            "value": {
              "status": "{{_ingest._value.status}}",
              "hostname": "{{_ingest._value.name}}"
            }
          }
        }
      }
    },
    {
      "foreach": {
        "field": "bf.servers",
        "processor": {
          "set": {
            "description": "Appends the IP array from the bf.servers array to the VM's field.",
            "field": "bf.server.{{_ingest._value.name}}.ip",
            "copy_from": "_ingest._value.ip.imt3003"
          }
        }
      }
    },
    {
      "remove": {
        "field": "bf.servers"
      }
    }
  ]
}
