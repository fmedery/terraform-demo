#!/bin/bash
set -x
#set -e

sleep 10
sudo apt-get -qq update

sudo apt-get -y install nginx

sudo systemctl enable nginx
sudo systemctl restart nginx


echo "Amazon AWS $(hostname) $1" | sudo tee /var/www/html/index.html
