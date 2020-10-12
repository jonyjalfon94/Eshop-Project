#!/bin/bash

# Install Docker

sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

#Install docker-compose

sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null
sudo chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version

# Create docker-compose.yml file
cat <<EOT >> docker-compose.yml
version: '3.4'
services:
 eshopwebmvc:
   image: jonyjalfon94/eshop-web
   environment:
     - ASPNETCORE_ENVIRONMENT=Docker
     - ASPNETCORE_URLS=http://+:80
   ports:
     - "5106:80"
   volumes:
     - ~/.aspnet/https:/root/.aspnet/https:ro
     - ~/.microsoft/usersecrets:/root/.microsoft/usersecrets:ro
 eshoppublicapi:
   image: jonyjalfon94/eshop-api
   environment:
     - ASPNETCORE_ENVIRONMENT=Docker
     - ASPNETCORE_URLS=http://+:80
   ports:
     - "5200:80"
   volumes:
     - ~/.aspnet/https:/root/.aspnet/https:ro
     - ~/.microsoft/usersecrets:/root/.microsoft/usersecrets:ro
EOT

# Run containers

sudo docker-compose up -d