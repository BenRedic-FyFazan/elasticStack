#!/bin/bash

script_dir=$(dirname $0)
ca=$script_dir/elasticsearch-ca.pem
elasticSearch=$(cat $script_dir/elasticsearch_ip.txt)
logsource=""
message=""
loglevel=0

# Parameters
while getopts ":s:m:l:" opt; do
  case $opt in
    s)
      logsource="$OPTARG"
      ;;
    m)
      message="$OPTARG"
      ;;
    l)
      loglevel="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Check if the message is provided
if [[ -z "$message" ]]; then
  echo "Usage: ./uclog -m <message> [-l <loglevel> -s <logsource>]"
  exit 1
fi

timestamp=$(date +"%Y-%m-%dT%H:%M:%S.%3N%z")
log_line="{\"@timestamp\": \"$timestamp\", \"bf.uc.log\": {\"source\": \"$logsource\", \"level\": $loglevel, \"message\": \"$message\"}}"

# Shipping to elasticsearch - MAKE CERTIFICATE GOOD ENOUGH TO NOT REQUIRE USER CREDENTIALS
curl -X POST \
-H "Content-Type: application/json" \
--data-binary "$log_line" \
--cacert "$ca" \
-u "elastic:superuser" \
"https://$elasticSearch:9200/logs-bf.uc.log/_doc/"
