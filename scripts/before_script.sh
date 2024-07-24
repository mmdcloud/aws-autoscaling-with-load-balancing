#!/bin/bash
set -x
echo "** (directory name)-api-prod process status **" >> /tmp/(directory name)-api-prod_deploy_logs
runuser -l ubuntu -c 'sudo pm2 status' | grep -wo (pm2 process name)
if [  $? -ne 0 ];
then
   echo "############################## pm2 not running #################################" >> /tmp/(directory name)-api-prod_deploy_logs
else
   echo "############################## pm2 already running Deleting ####################" >> /tmp/(directory name)-api-prod_deploy_logs
    runuser -l ubuntu -c 'sudo pm2 delete (pm2 process name)'
fi
 
rm -rf /home/ubuntu/(directory name)
 
if [ ! -d /home/ubuntu/(directory name) ]; then
runuser -l ubuntu -c 'mkdir -p /home/ubuntu/(directory name)' >> /tmp/(directory name)-prod_deploy_logs
fi