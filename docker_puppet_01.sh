##This is a test commit##
### Installation docker

## Install  docker
# cat /etc/yum.repos.d/docker.repo
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
# install 
yum -y install docker-engine containerd.io
# start service 
service docker start

## Install docker-compose
#way 1
yum -y install py-pip python-dev libffi-dev openssl-dev gcc libc-dev make
yum install docker-compose
#way2
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
#way-3 using pip 
pip install docker-compose 
#validate 
docker-compose --version

## Docker directory
mkdir myDocker

## cat > puppet-agent-01.sh 
PUPPET_AGENT_VERSION="5.5.1"
PUPPET_VERSION="5"
NETWORK_SUBNET='192.168.8.50/28'
PUPPET_MASTER='master01.shirishlnx.com'
PUPPET_MASTER_IP='192.168.8.12'
PUPPET_AGENT_HOSTNAME='puppetagent-01.shirishlnx.com'
PUPPET_AGENT_IP='192.168.8.51'
CONTAINER_NAME=${PUPPET_AGENT_HOSTNAME}
DOCKER_IMAGE='centos:centos7'
PUPPET_ENV='mytest'

## cat > docker-compose.yml
version: '3.1'
services:
  puppetagent:
    image: ${DOCKER_IMAGE}
    tty: true
    privileged: true
    hostname: ${PUPPET_AGENT_HOSTNAME}
    container_name: ${CONTAINER_NAME}
    environment:
      - PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH
    command:
      - /bin/bash
      - -c
      - |
       rpm -ivh https://yum.puppetlabs.com/puppet${PUPPET_VERSION}/puppet${PUPPET_VERSION}-release-el-7.noarch.rpm  &&
       yum -y install puppet-agent-${PUPPET_AGENT_VERSION}  &&
       echo ${PUPPET_AGENT_IP} ${PUPPET_AGENT_HOSTNAME} >>  /etc/hosts &&
       echo ${PUPPET_MASTER_IP} ${PUPPET_MASTER} puppet >> /etc/hosts &&
       puppet config set environment ${PUPPET_ENV} --section agent &&
       systemctl enable puppet &&
       puppet agent -t &&
       bash
    volumes:
      - ./docker-compose.yml:/tmp/docker-compose.yml
    networks:
      puppetnet:
        ipv4_address: ${PUPPET_AGENT_IP}

networks:
  puppetnet:
    driver: bridge
    ipam:
      config:
        - subnet: ${NETWORK_SUBNET}

#### RUN ####
# Launch docker for agent 
set -a
source  puppet-agent-01.sh 
docker-compose up -d --build
# Check container id 
docker ps 
-- OR -- 
DID=$(docker ps -l -q)
# check logs 
docker logs -f <id>
docker logs -f $DID
# login and check 
docker exec -it <id> bash 
docker exec -it $DID bash 

#### END ####