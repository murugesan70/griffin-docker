#!/bin/bash

# apt-get git and maven
apt-get update
apt-get install git -y
wget http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar -xvzf apache-maven-3.3.9-bin.tar.gz
ln -s apache-maven-3.3.9 maven
export PATH=/root/maven/bin:$PATH

# git clone griffin 
git clone https://github.com/apache/griffin.git
cd griffin/
git checkout master
/root/maven/bin/mvn clean package -DskipTests

# cp measure and service jar in directories
mkdir -p /root/measure
mkdir -p /root/service
cp measure/target/measure*.jar /root/measure/griffin-measure.jar
cp service/target/service*SNAPSHOT.jar /root/service/service.jar

# copy griffin service configs


# cleanup and remove
cd /root/
rmdir -rf /root/griffin
rmdir -rf /root/apache-maven-3.3.9 /root/maven
