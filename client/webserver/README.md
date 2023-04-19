# Logging to elasticsearch from apache
## Sending logs from a Docker swarm stack (IE set up with docker compose)
There are multiple ways to do this, one way is to store the logs produced by apache to a shared network volume (for example a gluster volume) 
and then run filebeat as one of the services on the stack. Most importantly we need to make sure the service can reach certain key files:
- filebeat.yml
    - This is filebeats configuration file
- elasticsearch-ca.pem
    - The certificate required to communicate with elasticsearch
- access.log
    - The file apache logs to.
     
You can see [here](./code/docker-compose.yml) for a full docker-compose example, or see beneath for the relevant parts:
```yaml
configs:
  filebeat_config:
    file: ./filebeat.yml
services:
  filebeat:
    image: docker.elastic.co/beats/filebeat:8.7.0
    configs:
      - source: filebeat_config
        target: /usr/share/filebeat/filebeat.yml
    user: root
    volumes:
      - type: bind
        source: /bf_logs/apache2
        target: /bf_logs/apache2
      - type: bind
        source: ./elasticsearch-ca.pem
        target: /usr/share/filebeat/elasticsearch-ca.pem

    networks:
      - bf
    deploy:
      placement:
        constraints:
          - node.role == manager
```

## Log storage
### Swarm (docker compose)

Make sure the apache logs are accessible outside of the containers, for example by binding the containers log folder to a folder on the host:

```yaml
services:
  web:
    volumes:
        - type: bind
          source: /var/log/apache2
          target: /bfdata/logs/apache2
```

#### Setting up gluster for log-storage
Create directories to be used by gluster:
```bash
sudo mkdir /bf_logs_brick 
sudo mkdir /bf_logs
```

Create a shared volume with the brick folders:
```bash
gluster volume create bf_logs replica 3 [server1]:/bf_logs_brick [server2]:/bf_logs_brick [server3]:/bf_logs_brick force
gluster volume start bf_logs
```

For example:
```bash
gluster volume create bf_logs replica 3 192.168.133.157:/bf_logs_brick 192.168.128.213:/bf_logs_brick 192.168.130.244:/bf_logs_brick force
gluster volume start bf_images
```

Then we need to mount the folders:
```bash
mount -t glusterfs [serverX]:bf_logs /bf_logs
```

Making sure the folders are fully accessible:
```bash
chmod 777 /bf_logs
```

And finally, remember to update your bootscript so that the new folder is also mountet when booting!
## logging

