#!/bin/bash

echo "-------Install Docker-------"

sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

echo "-------Install docker-compose-------"

sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null
sudo chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version

echo"-------Get docker-compose.yml and docker-compose.override.yml-------"

mkdir eshopDeploy
cd eshopDeploy
wget https://raw.githubusercontent.com/jonyjalfon94/eShopOnWeb/master/docker-compose.yml
wget https://raw.githubusercontent.com/jonyjalfon94/eShopOnWeb/master/docker-compose.override.yml

echo"-------Run containers-------"

sudo docker-compose up -d
