#!/bin/bash
# Contrail Command deployment
# Command example ./Contrail_Command-Install.sh
# Reference: https://www.juniper.net/documentation/en_US/contrail5.0/topics/example/install-contrail-command.html
# Date written 2018 October 8

# retrieve login/pwd for hub.juniper.net
printf "Repository hub.juniper.net Authentication \r"
read -p 'Username: ' CONTAINER_REGISTRY_USERNAME
read -sp 'Password: ' CONTAINER_REGISTRY_PASSWORD
echo
echo you entered the following credentials: $CONTAINER_REGISTRY_USERNAME / $CONTAINER_REGISTRY_PASSWORD (be careful, no syntax verification is done)

# retrieve parameters about the server
printf "Server details for Contrail Command installation (Mandatory to fill them): \r"
printf "Server SSH should be enable and root access allowed with password set to: c0ntrail123 \r"
read -p 'IP@ or FQDN : ' new-server1-ip
read -sp 'NTP server IP@/FQDN (you can use public : 0.pool.ntp.org): ' new-ntp-server


printf  "Install necesseary packages (Dokcer "entre autres").\r"
printf  "Operational Internet Access is needed.\r"
read -r -p "Wait 5 seconds or press any key to continue immediately" -t 5 -n 1 -s
# Example of multiple action with pause: sleep 5 && cd /var/www/html && git pull && sleep 3 && cd ..


yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
systemctl start docker

printf  "Authenticating to hub.juniper.net.\r"
docker login hub.juniper.net --username $CONTAINER_REGISTRY_USERNAME --password $CONTAINER_REGISTRY_PASSWORD
printf  "Pulling Contrail Init Containers.\r"
echo "Output of 'docker pull hub.juniper.net/contrail/contrail-node-init:5.0.1-0.214'"
sleep 3

# get and edit command_servers.yml file to reflect the user entered data
cd ~/
echo "Get the reference file from Gihub and copy it to ~/ or /home/ 'wget https://github.com/cakkac/contrail/raw/master/command_servers.yml' \r"
printf "Edit server parameters. \r"
sed -i "s/^$server1-ip.*/$new-server1-ip/" ~/command_servers.yml
sed -i "s/^$nep-server.*/$new-ntp-server/" ~/command_servers.yml
sed -i "s/^$container_reg_user.*/$CONTAINER_REGISTRY_USERNAME/" ~/command_servers.yml
sed -i "s/^$container_reg_pwd.*/$CONTAINER_REGISTRY_PASSWORD/" ~/command_servers.yml

echo "human verification 'cat ~/command_servers.yml | grep "ip:|container_registry|ntpserver"'"
sleep 3


#deploy Contrail Command only
printf "Ansible playbook for Contrail Command started"
docker run -t --net host -v ~/command_servers.yml:/command_servers.yml -d --privileged --name contrail_command_deployer hub.juniper.net/contrail/contrail-command-deployer:5.0.1-0.214


Echo "Command Contrail installation in progress: 'docker logs -f contrail_command_deployer'"
