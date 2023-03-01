#!/bin/bash -x

#For "ease" of use below
export ca_p12=/usr/share/elasticsearch/elastic-stack-ca.p12

## DON'T TOUCH WITHOUT GOING THROUGH THE TOOL AT THE SAME TIME!!
printf 'n\ny\n%s\n%s\n5y\nn\n\ny\n%s\n\ny\nn\n%s\n%s\n\n' \
"${ca_p12}" "${ca_PW}" "${ip4}" "${cert_http_PW}" "${cert_http_PW}" \
| sudo $usrElastic/bin/elasticsearch-certutil http

## This doesn't seem to be possible with http mode
#sudo $usrElastic/bin/elasticsearch-certutil http \
#--ca-cert $usrElastic/elastic-stack-ca.p12 \
#--ca-pass $ca_PW \
#--days 1825 \
#--pass $cert_PW \
#--out $usrElastic/elasticsearch-ssl-http.zip 

# Unzipping, moving, setting rights and copying http.p12
sudo unzip $usrElastic/elasticsearch-ssl-http.zip -d $usrElastic 
sudo mv $usrElastic/elasticsearch/http.p12 $etcElastic/http.p12
sudo chmod 664 $etcElastic/http.p12
sudo cp $etcElastic/http.p12 $etcElastic/http.p12

# Moving, setting rights and copying elasticsearch-ca.pem 
sudo mv $usrElastic/kibana/elasticsearch-ca.pem $etcElastic/elasticsearch-ca.pem
sudo chmod 664 $etcElastic/elasticsearch-ca.pem
sudo cp $etcElastic/elasticsearch-ca.pem $etcKibana/elasticsearch-ca.pem
sudo cp $etcElastic/elasticsearch-ca.pem $ca

## Starting and verifying that elastic is running.
sudo systemctl daemon-reload
sudo systemctl start elasticsearch

# Wait for service to be active for 2 minutes, if it fails on the first try, it restarts the service, 
# if it fails to run for 2 minutes the second try, it exits the script
service_name="elasticsearch.service"
for i in {1..4}; do
  service_active=$(systemctl is-active --quiet $service_name && echo 1 || echo 0)
  if [[ $service_active -eq 1 ]]; then
    sleep 30
    service_active=$(systemctl is-active --quiet $service_name && echo 1 || echo 0)
    if [[ $service_active -eq 1 ]]; then
      sleep 90
      break
    fi
  fi
  systemctl restart $service_name
done

# Check if service is still active
if [[ $service_active -ne 1 ]] || ! systemctl is-active --quiet $service_name; then
  exit 1
fi

# Setting new passwords and adding to keystores
printf 'y\n%s\n%s\n' "${elastic_SU_PW}" "${elastic_SU_PW}" | sudo $usrElastic/bin/elasticsearch-reset-password --username $elastic_SU -i
printf 'y\n%s\n%s\n' "${kibana_U_PW}" "${kibana_U_PW}" | sudo $usrElastic/bin/elasticsearch-reset-password --username $kibana_U -i
#sudo $usrKibana/bin/kibana-keystore create ## Might possibly require user input -update: installer takes care of it... probably
sudo chown root:kibana $usrKibana/bin/kibana-keystore
echo "${kibana_U_PW}" | sudo $usrKibana/bin/kibana-keystore add elasticsearch.password --stdin

# kibana.yml config
echo "elasticsearch.username: ${kibana_U}" | sudo tee -a $etcKibana/kibana.yml
echo "elasticsearch.password: ${kibana_U_PW}" | sudo tee -a $etcKibana/kibana.yml
echo "server.port: 5601" | sudo tee -a $etcKibana/kibana.yml
echo "server.host: 0.0.0.0" | sudo tee -a $etcKibana/kibana.yml
echo "server.ssl.enabled: true" | sudo tee -a $etcKibana/kibana.yml
echo "server.ssl.keystore.path: /etc/kibana/http.p12" | sudo tee -a $etcKibana/kibana.yml
echo "server.ssl.keystore.password: ${cert_http_PW}" | sudo tee -a $etcKibana/kibana.yml
echo "elasticsearch.hosts: https://${ip4}:9200" | sudo tee -a $etcKibana/kibana.yml
echo "elasticsearch.ssl.certificateAuthorities: /etc/kibana/elasticsearch-ca.pem" | sudo tee -a $etcKibana/kibana.yml
echo "xpack.encryptedSavedObjects.encryptionKey: 'salkdjfhasldfkjhasdlfkjhasdflkasjdfhslkajfhasldkfjhasdlaksdjfh'" | sudo tee -a $etcKibana/kibana.yml

## STARTING KIBANA
sudo systemctl daemon-reload
sudo systemctl start kibana
