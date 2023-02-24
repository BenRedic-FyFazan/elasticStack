# Apache ingest_pipeline requirements:

## logs-apache.access-third-party
#### Fetches the access logs.

## logs-apache.access-bookface 
Current pattern (24.02.23):
%{IPORHOST:source.address} (?:%{IPORHOST:source.forwarded_for}|-) %{USER:auth.user} %{USER:auth.unknown} \[%{HTTPDATE:apache.access.time}\] "%{WORD:http.request.method} %{URIPATHPARAM:http.request.php_file}\?%{DATA:http.request.php_file_extension} HTTP/%{NUMBER:http.version}" %{NUMBER:http.response.status_code:long} %{NUMBER:http.response.body.bytes:long} "%{DATA:http.request.referrer}" "%{DATA:user_agent.original}" %{NUMBER:http.response.time:int}

processes the logs

### Logged but not processed
- PHP files used by HTTP requests
