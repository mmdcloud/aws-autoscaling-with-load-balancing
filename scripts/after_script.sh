#!/bin/bash
set -x
chown -R ubuntu:ubuntu /home/ubuntu/(directory-name)/
echo  "***Installing npm package ***" >> /tmp/(directory-name)-api-prod_deploy_logs
echo >> /tmp/(directory-name)-api-prod_deploys_logs
#runuser -l ubuntu -c 'cd /home/ubuntu/(directory-name) && npm install'
#runuser -l ubuntu -c 'cd /home/ubuntu/(directory-name) && npm install --unsafe-perm'
#runuser -l ubuntu -c 'cd /home/ubuntu/(directory-name) && npm run build'
sleep 10
echo "***starting (pm2 process name)-backend-admin-api-prod application ***" >> /tmp/(directory-name)-api-prod_deploy_logs
runuser -l ubuntu -c 'cd /home/ubuntu/(directory-name) && sudo pm2 start dist/src/server.js --name (pm2 process name)  --silent' >> /tmp/(directory-name)-api-prod_deploy_logs
s1=`pm2 status | grep -we (pm2 process name) | awk '{print $12}'`
sleep 5
s2=`pm2 status | grep -we (pm2 process name) | awk '{print $12}'`
if [ $s1 == $s2 ]
then
echo "BUILD SUCCESSFUL" >> /tmp/(directory-name)-api-prod_deploy_logs
echo >> /tmp/(directory-name)-api-prod_deploy_logs
else
echo "Node process is restarting" >> /tmp/(directory-name)-api-prod_deploy_logs
echo >> /tmp/(directory-name)-api-prod_deploy_logs
fi