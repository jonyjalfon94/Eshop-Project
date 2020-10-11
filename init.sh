#!/bin/bash

# Install Docker

sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Pull container images

docker pull jonyjalfon94/eshop-web
docker pull jonyjalfon94/eshop-api
docker run --name eshopweb --rm -it -p 5106:5106 jonyjalfon94/eshop-web
docker run --name eshopapi --rm -it -p 5200:5200 jonyjalfon94/eshop-api


# Install docker-compose

# sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null
# sudo chmod +x /usr/local/bin/docker-compose
# ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
# docker-compose --version

# # Install git

# sudo yum install git -y
# sudo yum update -y

# # Clone repository

# git clone https://github.com/jonyjalfon94/eShopOnWeb.git
# cd eShopOnWeb
# sudo docker-compose build
# sudo docker-compose up -d