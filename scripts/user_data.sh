#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx

sudo apt update
curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install nodejs -y