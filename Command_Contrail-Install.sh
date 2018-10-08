#!/bin/bash
# Contrail Command deployment
# Command example ./Contrail_Command-Install.sh
# Reference: https://www.juniper.net/documentation/en_US/contrail5.0/topics/example/install-contrail-command.html
# Date written 2018 October 8

#need wget and change chmod for script
# install wget package to retrieve files from Github
# yum install -y wget
# to run this script: sh Contrail_Command-Install.sh


# retrieve login/pwd for hub.juniper.net
printf "Repository hub.juniper.net Authentication \n"
read -p 'Username: ' CONTAINER_REGISTRY_USERNAME
read -sp 'Password: ' CONTAINER_REGISTRY_PASSWORD
echo

# retrieve parameters about the server
printf "Server details for Contrail Command installation (Mandatory to fill them): \n"
printf "login to run this shell should be root :) \n"
read -p 'IP@ or FQDN : ' NewServer1IP
read -p 'NTP server IP@/FQDN (you can use public : 0.pool.ntp.org): ' NewNTPServer

# Login/pwd on the server should be root/c0ntrail123 - not mandatory for Contrail Command installation but for Contrail Networking..
# Allow Root login via SSH
#	(in file instance.yml, no indication about a non-root user for SSH Login….
#		/etc/ssh/sshd_config
#			# Authentication:
#           PermitRootLogin yes
#
# then restart service: service sshd restart

printf  "\n Install necesseary packages (Dokcer "entre autres").\n"
printf  "Operational Internet Access is needed.\n"
read -r -p "Wait 5 seconds or press any key to continue immediately" -t 5 -n 1 -s
# Example of multiple action with pause: sleep 5 && cd /var/www/html && git pull && sleep 3 && cd ..


yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
systemctl start docker

printf  "\n Authenticating to hub.juniper.net.\n"
docker login hub.juniper.net --username $CONTAINER_REGISTRY_USERNAME --password $CONTAINER_REGISTRY_PASSWORD
printf  "Pulling Contrail Init Containers.\n"
echo "Output of 'docker pull hub.juniper.net/contrail/contrail-node-init:5.0.1-0.214'"
sleep 3

# get and edit command_servers.yml file to reflect the user entered data
cd ~/
printf "Downloading YAML file Command_Servers.yml from Gihub and copy it to ~/ or /home/"
wget https://raw.githubusercontent.com/cakkac/contrail/master/command_servers.yml
printf "\n Edit server parameters. \n"
sed -i "s/^$Server1IP.*/$NewServer1IP/" ~/command_servers.yml
printf "##### IP@ done! #####"
sed -i "s/^$NTPServer.*/$NewNTPServer/" ~/command_servers.yml
printf "NTP Server set! #####"
sed -i "s/^$container_reg_user.*/$CONTAINER_REGISTRY_USERNAME/" ~/command_servers.yml
printf " Registry user set! #####"
sed -i "s/^$container_reg_pwd.*/$CONTAINER_REGISTRY_PASSWORD/" ~/command_servers.yml
printf " Registry Pasword set! ##### \n ______ Settings completed!______ "

echo "\n human verification 'cat ~/command_servers.yml | grep "ip:|container_registry|ntpserver"'"
sleep 3


#deploy Contrail Command only
printf "\n Ansible playbook for Contrail Command started"
docker run -t --net host -v ~/command_servers.yml:/command_servers.yml -d --privileged --name contrail_command_deployer hub.juniper.net/contrail/contrail-command-deployer:5.0.1-0.214


Echo "\n Command Contrail installation in progress: 'docker logs -f contrail_command_deployer'"
