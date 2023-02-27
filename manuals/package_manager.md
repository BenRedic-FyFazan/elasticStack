## Installation:
 - docker pull docker.elastic.co/package-registry/distribution:8.6.2
 - Run using one of the commands below
 - Make sure kibana is pointed to the self-hosted package registry, add the following line in kibana.yml:
    - xpack.fleet.registryUrl: "http://[IP TO elpr]:8080"
 
## Elastic Package registry launch

#### With TSL (Unused atm)
sudo docker run -itd -p 443:443 \
  -p 8080:8080 \
  --name bookface-elpr \
  -v /home/ubuntu/elpr_cert/elastic-private.key:/etc/ssl/elastic-private.key:ro \
  -v /home/ubuntu/elpr_cert/elastic-full.crt:/etc/ssl/elastic-full.crt:ro \
  -e EPR_ADDRESS=0.0.0.0:443 \
  -e EPR_TLS_KEY=/etc/ssl/elastic-private.key \
  -e EPR_TLS_CERT=/etc/ssl/elastic-full.crt \
  docker.elastic.co/package-registry/distribution:8.6.2


#### Without TLS/SSL:

sudo docker run -itd -p 8080:8080 \
  --name bookface-elpr \
  -v /home/ubuntu/package-storage:/packages/package-storage \
  docker.elastic.co/package-registry/distribution:8.6.2


## Uploading integrations
