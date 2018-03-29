#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

echo "----------------------------------------------------------------------------------"
echo "***** Validating and Installing prerequisites for CueOps stack deployment ***** "
echo "----------------------------------------------------------------------------------"

sleep 3
echo -e "\n\n"
echo "------------------------------------------------------------"
echo "***** Validating if Docker installed *****"
echo "------------------------------------------------------------"

sudo dpkg -l | grep docker > /dev/null 2>&1

if [ $? -eq 0 ]; then
	
	echo -e "${green}\xE2\x9C\x94 ${reset}Docker installed..."
else
	echo -e "${red}\xE2\x9D\x8C ${reset}Docker not found...Installing Docker.."
	sudo apt-get update
    sudo apt-get install -y apt-transport-https 
    sudo apt-get install -y ca-certificates 
    sudo apt-get install -y  curl 
    sudo apt-get install -y software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce=17.12.1~ce-0~ubuntu
    echo -e "${green}\xE2\x9C\x94 ${reset}Docker installed..."
fi

sleep 3
echo -e "\n\n"
echo "----------------------------------------------------------------------------"
echo "***** Validating if Docker Swarm installed and Certs are Generated *****"
echo "----------------------------------------------------------------------------"

if [ -f ca.pem ]; then
	echo -e "${green}\xE2\x9C\x94 ${reset}Certs Already Generated..!!"
	elif sudo docker node ls > /dev/null 2>&1; then
		echo -e "${green}\xE2\x9C\x94 ${reset}Docker Swarm Alredy Initialized..!!"	
else
	sudo docker swarm init 
	echo -e "${green}\xE2\x9C\x94 ${reset}Docker Swarm Initialized..!!"
	sleep 3
	echo -e "{green}exporting docker over TCP port 2376....!${reset}"
	sleep 1
	cd /home/ubuntu
	export ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4/)
	openssl genrsa -out ca-key.pem 4096
	openssl req -new -x509 -nodes -days 365 -subj "/CN=${HOSTNAME}" -key ca-key.pem -sha256 -out ca.pem	
	openssl genrsa -out server-key.pem 4096
	openssl req -subj "/CN=${ip}" -sha256 -new -key server-key.pem -out server.csr
	echo subjectAltName = DNS:${ip},IP:${ip} >> extfile.cnf
	echo extendedKeyUsage = serverAuth >> extfile.cnf
	openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem \
  	-CAcreateserial -out server-cert.pem -extfile extfile.cnf
	openssl genrsa -out key.pem 4096
	openssl req -subj '/CN=client' -new -key key.pem -out client.csr
	echo extendedKeyUsage = clientAuth >> extfile.cnf
	openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem \
	 -CAcreateserial -out cert.pem -extfile extfile.cnf
	sudo rm -v client.csr server.csr
	chmod -v 0400 ca-key.pem key.pem server-key.pem
	chmod -v 0444 ca.pem server-cert.pem cert.pem
        echo -e "${green}\xE2\x9C\x94 ${reset}Docker certs generated..."
	sudo service docker stop
	sudo nohup dockerd -H=unix:///var/run/docker.sock --tlsverify --tlscacert=ca.pem --tlscert=server-cert.pem --tlskey=server-key.pem -H=tcp://0.0.0.0:2376 &
        echo -e "${green}\xE2\x9C\x94 ${reset}Docker daemon exported over TCP 2376 securely..."
fi 


sudo groupadd docker 
sudo gpasswd -a $USER docker 
sudo /usr/bin/newgrp docker
