## What is CueOps?

CueOps is an integrated open source DevOps and Integration Platform which works out of the box with Docker evironment and provides Continuous Integration, Continuous Delivery, Management, Logging and Monitoring.

CueOps gives you out of the box services that assist you when building Microservices, monoliths or any application in a linux container (Docker) environment and is built on top of Docker Swarm cluster.

## PreRequisites
## 1. Source Control Management (GitHub)
   - A GitHub Bot account that should have access to clone the repo, creating webhooks etc.  
   - One repository containing all the Docker compose files.
   - Don't familiar with Docker compose files? You can find the sample docker compose file [here](./docker-compose.yml).

## 2. Docker
   - Application stack should be running on Docker. All you need is a Dockerfile residing into your repository. 
   - [Docker Swarm Mode](https://docs.docker.com/engine/swarm/). 
   - [Docker compose](https://docs.docker.com/compose/overview/).
   - [Docker Hub](https://hub.docker.com/) username and password to store the Application stack Docker Images.
   - Docker Swarm Manager Certificates and IP. 
   - You can execute this [script](./swarm-certs.sh) to generate docker swarm certificates.
  
## 3. Alerts and Notification receivers
   - CueOps supports several tools like Slack, Email etc.
   - #Slack
      - Slack Username
      - Slack Channel name (Ex. #notification)
      - Slack incoming webhhok url. 
     ### Obtaining Slack incoming webhhok url

      To configure a webhook and obtain a URL, go to https://[your company].slack.com/services/new/incoming-webhook, select a
channel you would like the messages to be posted to and click on "Add Incoming WebHooks Integration" button.

      ![Step 1](https://github.com/StackStorm/st2contrib/blob/master/_images/slack_generate_webhook_url_1.png)

      On the next page you will find an automatically generated webhook URL.

      ![Step 2](https://github.com/StackStorm/st2contrib/blob/master/_images/slack_generate_webhook_url_2.png)


   
   

