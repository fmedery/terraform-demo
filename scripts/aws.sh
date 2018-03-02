#!/bin/bash
set -x
#set -e

sleep 10
sudo apt-get update

sudo apt-get -y install nginx

sudo systemctl enable nginx
sudo systemctl restart nginx


echo "Amazon AWS $(hostname)" | sudo tee /var/www/html/index.html
