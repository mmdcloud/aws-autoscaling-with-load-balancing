#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
sudo apt update
curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install nodejs -y
cd /home/ubuntu
mkdir nodeapp
git clone https://github.com/mmdcloud/aws-autoscaling-with-load-balancing
cd aws-autoscaling-with-load-balancing
cp -r . /home/ubuntu/nodeapp/
cd /home/ubuntu/nodeapp/
sudo cp scripts/nodejs_nginx.config /etc/nginx/sites-available/default
sudo service nginx restart
sudo npm i
sudo npm i -g pm2
pm2 start server.mjs

sudo apt-get install ruby-full ruby-webrick wget -y
cd /tmp
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/releases/codedeploy-agent_1.3.2-1902_all.deb
mkdir codedeploy-agent_1.3.2-1902_ubuntu22
dpkg-deb -R codedeploy-agent_1.3.2-1902_all.deb codedeploy-agent_1.3.2-1902_ubuntu22
sed 's/Depends:.*/Depends:ruby3.0/' -i ./codedeploy-agent_1.3.2-1902_ubuntu22/DEBIAN/control
dpkg-deb -b codedeploy-agent_1.3.2-1902_ubuntu22/
sudo dpkg -i codedeploy-agent_1.3.2-1902_ubuntu22.deb
sudo systemctl list-units --type=service | grep codedeploy
sudo service codedeploy-agent status
