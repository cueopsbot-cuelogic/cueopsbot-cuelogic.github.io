#!/bin/bash
set -e

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
docker -v
if [ $? -eq 0 ]; then
	
	echo -e "${green}\xE2\x9C\x94 ${reset}Docker installed..."
else
	echo -e "${red}\xE2\x9D\x8C ${reset}Docker not found..."
fi


sleep 3
echo -e "\n\n"
echo "------------------------------------------------------------"
echo "***** Validating if Docker Compose installed *****"
echo "------------------------------------------------------------"
docker-compose -v
if [ $? -eq 0 ]; then
	
	echo -e "${green}\xE2\x9C\x94 ${reset}Docker Compose installed..."
else
	echo -e "${red}\xE2\x9D\x8C ${reset}Docker Compose not found..."
fi


sleep 3
echo -e "\n\n"
echo "------------------------------------------------------------"
echo "***** Validating operating system limits on mmap counts *****"
echo "------------------------------------------------------------"
CURRENT_MAP_COUNT=$(sysctl vm.max_map_count)
echo "Current operating system limit ${red}${CURRENT_MAP_COUNT}${reset} is likely to be too low, which may result in out of memory exceptions for Elasticsearch.." 
echo "Increasing the limits to run Elasticsearch container to avoid out of memory exceptions.."
INCREASED_MAP_COUNT=$(sysctl -w vm.max_map_count=262144)
echo -e "updated map count limit : ${green}\xE2\x9C\x94 ${INCREASED_MAP_COUNT}${reset}"



