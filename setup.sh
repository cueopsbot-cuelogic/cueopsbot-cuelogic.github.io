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
	sleep 3
	if [ -f ca.pem ]; then
		echo -e "${green}\xE2\x9C\x94 ${reset}Certs Already Generated..!!"
        else
		echo "exporting docker over TCP port 2376....!"
        	echo "--------- generating certs --------------"
		cd /home/ubuntu
		export ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4/)
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
else
	echo -e "${red}\xE2\x9D\x8C ${reset}Docker not found... installing now !!"
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
	
    sleep 7
	echo "exporting docker over TCP port 2376....!"
    echo "--------- generating certs --------------"

	cd /home/ubuntu

	export ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4/)

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
	#chmod -v 0444 key.pem
	chmod -v 0444 ca.pem server-cert.pem cert.pem

        echo -e "${green}\xE2\x9C\x94 ${reset}Docker certs generated..."
	sudo service docker stop
	sudo dockerd -H=unix:///var/run/docker.sock --tlsverify --tlscacert=ca.pem --tlscert=server-cert.pem --tlskey=server-key.pem -H=tcp://0.0.0.0:2376 &
        echo -e "${green}\xE2\x9C\x94 ${reset}Docker daemon exported over TCP 2376 securely..."
fi 

sleep 5
if sudo docker node ls > /dev/null 2>&1; then
	echo -e "${green}\xE2\x9C\x94 ${reset}Docker Swarm Alredy Initialized..!!"
	if docker network ls | grpe cuenet > /dev/null 2>&1 && docker service ls | grep cueops-dashboard\|cueops-bootloader > /dev/null 2>&1; then
		echo -e "${green}Cueops Stack Already started..!!"
	else
		sudo docker network create --driver=overlay --subnet=192.168.0.0/16 cuenet > /dev/null 2>&1
		sudo docker service create --name mongo --network cuenet mongo:3.4
		sudo docker service create --name mongoserver --network cuenet mongo:3.4
		sudo docker service create --name cueops-dashboard --publish 81:3000 -e REACT_APP_MACHINE_IP=$ip --network cuenet cueops/ui:23
		sudo docker service create --name cueops-bootloader --publish 3010:3010 -e MACHINE_IP=$ip  --mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock --network cuenet cueops/bootloader:16
        echo " "
		echo " "
		echo " "

        echo "          ___| __|_  ) "
        echo "          __| (__   /"
        echo "          ___|\__|___|  "
        echo "  "
		echo "  "
        echo " __||  |__| _ \ O )(  _|"
        echo "(__ |L'|_| |_|| ,~ _\ \              powered by CUELOGIC PVT. LTD."
        echo "\__||__|__| __/_| ( __/"

        echo " "
		echo " "
		echo " "

        echo -e "${green}\xE2\x9C\x94 Your Cueops-Dashboard URL is ::  http://${ip}:81${reset}"
	fi		
else
	echo "Initializing Docker Swarm.."
    sudo docker swarm init
	sudo mkdir -p /mnt/glusterstorage
	sudo chmod 0777 -R /mnt
	sudo docker network create --driver=overlay --subnet=192.168.0.0/16 cuenet
	sudo docker service create --name mongo --network cuenet mongo:3.4
	sudo docker service create --name mongoserver --network cuenet mongo:3.4
#	docker pull traefik
#	wget https://raw.githubusercontent.com/cueopsbot-cuelogic/cueopsbot-cuelogic.github.io/master/traefik.toml
#	docker run -d -p 8080:8080 -p 80:80 -v home/ubuntu/traefik.toml:/etc/traefik/traefik.toml -v /var/run/docker.sock:/var/run/docker.sock traefik
        #docker pull cueops/ui:10
    sudo docker service create --name cueops-dashboard --publish 81:3000 -e REACT_APP_MACHINE_IP=$ip --network cuenet cueops/ui:22
	sudo docker service create --name cueops-bootloader --publish 3010:3010 -e MACHINE_IP=$ip  --mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock --network cuenet cueops/bootloader:14

	echo " "
	echo " "
	echo " "

    echo "          ___| __|_  ) "
    echo "          __| (__   /"
    echo "          ___|\__|___|  "
    echo "  "
	echo "  "
    echo " __||  |__| _ \ O )(  _|"
    echo "(__ |L'|_| |_|| ,~ _\ \              powered by CUELOGIC PVT. LTD."
    echo "\__||__|__| __/_| ( __/"

    echo " "
	echo " "
	echo " "
 
    echo -e "${green}\xE2\x9C\x94 ${reset}Your Cueops-Dashboard is available on port 81 http://${ip}:81"
fi

sleep 3
echo -e "\n\n"
echo "------------------------------------------------------------"
echo "***** Validating operating system limits on mmap counts *****"
echo "------------------------------------------------------------"
CURRENT_MAP_COUNT=$(sysctl vm.max_map_count)
echo "Current operating system limit ${red}${CURRENT_MAP_COUNT}${reset} is likely to be too low, which may result in out of memory exceptions for Elasticsearch.." 
echo "Increasing the limits to run Elasticsearch container to avoid out of memory exceptions.."
INCREASED_MAP_COUNT=$(sudo sysctl -w vm.max_map_count=262144)
echo -e "updated map count limit : ${green}\xE2\x9C\x94 ${INCREASED_MAP_COUNT}${reset}"

sudo groupadd docker 
sudo gpasswd -a $USER docker 
newgrp docker
