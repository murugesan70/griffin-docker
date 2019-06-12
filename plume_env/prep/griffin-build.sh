#!/bin/bash

# apt-get git and maven
#apt-get update
apt-get install git -y
#wget http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
#tar -xvzf apache-maven-3.3.9-bin.tar.gz
#ln -s apache-maven-3.3.9 maven
#export PATH=/apache/maven/bin:$PATH

# git clone griffin 
#git clone https://github.com/apache/griffin.git
#cd griffin/
#echo "$pwd"
#git checkout griffin-0.5.0
#/apache/maven/bin/mvn clean install -DskipTests

# cp measure and service jar in directories
mkdir -p /root/measure
mkdir -p /root/service
mkdir -p /root/jars

cp /apache/griffin-jars/0.5.0/griffin-measure.jar     /root/measure
cp /apache/griffin-jars/0.5.0/service.jar             /root/service
cp /apache/griffin-jars/0.5.0/hive-serde-0.11.0.jar   /root/jars

#cp measure/target/measure*.jar /root/measure/griffin-measure.jar
#cp service/target/service*SNAPSHOT.jar /root/service/service.jar

# copy griffin service configs


# cleanup and remove
cd /root/
#rmdir --ignore-fail-on-non-empty -p /apache/griffin
#rm /apache/maven
#rmdir --ignore-fail-on-non-empty -p /apache/apache-maven-3.3.9 
