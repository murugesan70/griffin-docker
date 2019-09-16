#!/bin/bash

# griffin
mkdir -p /root/measure
mkdir -p /root/service

aws s3 cp s3://plume-dist/griffin/griffin-0.6.0-auth-plume-bin.tar.gz ./
if [ $? -eq 0 ]; then
    tar -xvf griffin-0.6.0-auth-plume-bin.tar.gz

    # griffin service api auth
    # built from https://github.com/plume-design/griffin.git
    # branch griffin-221
    ln -s /apache/griffin-0.6.0-auth-plume/griffin-measure.jar     /root/measure
    ln -s /apache/griffin-0.6.0-auth-plume/service.jar             /root/service

    # cleanup and remove
    rm griffin-0.6.0-auth-plume-bin.tar.gz
else
    # git
    apt-get update
    apt-get install git -y

    # maven
    wget http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
    tar -xvzf apache-maven-3.3.9-bin.tar.gz
    ln -s apache-maven-3.3.9 maven
    export PATH=/apache/maven/bin:$PATH

    # git clone griffin
    git clone https://github.com/plume-design/griffin.git
    cd griffin/
    echo "$pwd"
    # griffin service api auth
    # currently implemented only in our repo (plume-design/griffin)
    # in this branch (griffin-221)
    git checkout griffin-221
    /apache/maven/bin/mvn clean install -DskipTests

    cp measure/target/measure-*-SNAPSHOT.jar /root/measure/griffin-measure.jar
    cp service/target/service-*-SNAPSHOT.jar /root/service/service.jar

    # cleanup and remove
    rmdir --ignore-fail-on-non-empty -p /apache/griffin
    rm /apache/maven
    rmdir --ignore-fail-on-non-empty -p /apache/apache-maven-3.3.9
fi

cd /root/
