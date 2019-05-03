#!/bin/bash

# java 8
wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" \
http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz \
-O jdk8-linux-x64.tar.gz
tar -xvzf jdk8-linux-x64.tar.gz
ln -s jdk1.8.0_131 jdk

# postgresql
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
apt-get update && apt-get -y -q install python-software-properties software-properties-common \
&& apt-get -y -q install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3
echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# hadoop
wget https://archive.apache.org/dist/hadoop/core/hadoop-2.7.3/hadoop-2.7.3.tar.gz
tar -xvf hadoop-2.7.3.tar.gz
ln -s hadoop-2.7.3 hadoop

# scala
wget https://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.tgz
tar -xvf scala-2.11.8.tgz
ln -s scala-2.11.8 scala

# spark
wget http://archive.apache.org/dist/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz
tar -xvf spark-2.2.1-bin-hadoop2.7.tgz
ln -s spark-2.2.1-bin-hadoop2.7 spark

# hive
wget https://www.apache.org/dist/hive/hive-2.3.4/apache-hive-2.3.4-bin.tar.gz
tar -xvf apache-hive-2.3.4-bin.tar.gz
ln -s apache-hive-2.3.4-bin hive

# livy
wget http://archive.cloudera.com/beta/livy/livy-server-0.3.0.zip
unzip livy-server-0.3.0.zip
ln -s livy-server-0.3.0 livy

#elasticsearch
#wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.4.0.deb
#dpkg -i elasticsearch-5.4.0.deb
#update-rc.d elasticsearch defaults

# mongo-hadoop connectors
wget https://repo1.maven.org/maven2/org/mongodb/mongo-java-driver/3.4.3/mongo-java-driver-3.4.3.jar
mkdir -p mongodb
mv mongo-java-driver-*.jar mongodb
ln -s mongodb/mongo-java-driver-3.4.3.jar hive/lib
wget https://repo1.maven.org/maven2/org/mongodb/mongo-hadoop/mongo-hadoop-core/1.5.2/mongo-hadoop-core-1.5.2.jar
wget https://repo1.maven.org/maven2/org/mongodb/mongo-hadoop/mongo-hadoop-hive/1.5.2/mongo-hadoop-hive-1.5.2.jar
mv mongo-hadoop-*.jar mongodb
ln -s mongodb/mongo-hadoop-core-1.5.2.jar hive/lib
ln -s mongodb/mongo-hadoop-hive-1.5.2.jar hive/lib

# aws java sdk and hadoop-aws jars
wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar
mkdir -p aws-sdk
mv aws-java-sdk*.jar aws-sdk
ln -s aws-sdk/aws-java-sdk-1.7.4.jar hive/lib
ln -s aws-sdk/aws-java-sdk-1.7.4.jar hadoop/share/hadoop/tools/lib
ln -s aws-sdk/aws-java-sdk-1.7.4.jar spark/jars

wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.3/hadoop-aws-2.7.3.jar
mv hadoop-aws-*.jar aws-sdk
ln -s aws-sdk/hadoop-aws-2.7.3.jar hive/lib
ln -s aws-sdk/hadoop-aws-2.7.3.jar hadoop/share/hadoop/tools/lib
ln -s aws-sdk/hadoop-aws-2.7.3.jar spark/jars

#remove install packages
rm jdk8-linux-x64.tar.gz hadoop-2.7.3.tar.gz scala-2.11.8.tgz spark-2.2.1-bin-hadoop2.7.tgz apache-hive-2.3.4-bin.tar.gz livy-server-0.3.0.zip

#remove extra files
rm -rf hadoop/share/doc
