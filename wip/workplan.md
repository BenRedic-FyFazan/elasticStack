# 1. Finish autodeploy of the apache backend
    - DONE: Install apache integration assets
        - Done via REST endpoint.
        
        
sudo cockroach start --insecure --store=/bfdata --listen-addr=0.0.0.0:26257 --http-addr=0.0.0.0:8080 --background --join=localhost:26257
