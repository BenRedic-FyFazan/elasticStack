#!/bin/bash -x

curl -u elastic:superuser --cacert /home/ubuntu/elkStack_DCSG2003/elasticsearch-ca.pem --head  --request GET "https://127.0.0.1:5601/api/status"


MAX_WAIT=300
start_time=$(date +%s)
while true; do
  response=$(curl -u $elastic_SU:$elastic_SU_PW --cacert $ca --silent --head --request GET "https://localhost:5601/api/status")
  if [[ $response == *"200 OK"* ]]; then
    break
  fi
  current_time=$(date +%s)
  if (( current_time - start_time >= MAX_WAIT )); then
    echo "Timeout waiting for server to become available"
    exit 1
  fi
  sleep 10
done
