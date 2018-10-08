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



ansible-playbook -i all.inv 03-IP-Address/deploy-addresses.yml
printf  "Addresses applied.\r"
sleep 3
ansible-playbook -i all.inv 04-Routing/ISIS/deploy-isis.yml
printf "ISIS Routing Protocol installed.\r"
sleep 3
