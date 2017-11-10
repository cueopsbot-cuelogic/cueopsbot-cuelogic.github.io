## What is CueOps?

CueOps is an integrated open source DevOps and Integration Platform which works out of the box with Docker evironment and provides Continuous Integration, Continuous Delivery, Management, Logging and Monitoring.

CueOps gives you out of the box services that assist you when building Microservices, monoliths or any application in a linux container (Docker) environment and is built on top of Docker Swarm cluster.

## PreRequisites
## 1. Source Control Management (GitHub)
   - A GitHub Bot account that should have access to clone the repo, creating webhooks etc.  
   - Ops Repository containing all the Docker compose files.
   - Don't familiar with Docker compose files? You can find the sample docker compose file [here](./docker-compose.yml).

## 2. Docker
   - Application stack should be running on Docker. All you need is a Dockerfile residing into your repository. 
   - [Docker Swarm Mode](https://docs.docker.com/engine/swarm/). 
   - [Docker compose](https://docs.docker.com/compose/overview/). Installation Link: [https://docs.docker.com/compose/install/]
   - [Docker Hub](https://hub.docker.com/) username and password to store the Application stack Docker Images.
   - Docker Swarm Manager Certificates and IP. 
   - You can execute the [script](./swarm-certs.sh) to generate docker swarm certificates.
   
   

