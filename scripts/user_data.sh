#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
sudo apt update
curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install nodejs -y
git clone https://github.com/mmdcloud/aws-autoscaling-with-load-balancing
cd aws-autoscaling-with-load-balancing
sudo cp scripts/nodejs_nginx.config /etc/nginx/sites-available/default
sudo service nginx restart
sudo npm i
sudo npm i -g pm2
pm2 start server.mjs
