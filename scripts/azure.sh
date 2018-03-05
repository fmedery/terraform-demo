#!/bin/bash
set -x
#set -e

sleep 10
sudo apt-get update

sudo apt-get -y install nginx

sudo systemctl enable nginx
sudo systemctl restart nginx


echo "Microsoft AZURE $(hostname) $1" | sudo tee /var/www/html/index.html
