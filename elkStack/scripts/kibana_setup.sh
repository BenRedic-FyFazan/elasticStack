#!/bin/bash -x

# Kibana install
sudo apt-get install kibana -y
sudo systemctl daemon-reload
sudo systemctl enable kibana


