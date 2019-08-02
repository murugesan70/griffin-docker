#!/bin/bash

# pids
mkdir -p /apache/pids

# hadoop
cp conf/hadoop/* hadoop/etc/hadoop/
sed s/HOSTNAME/localhost/ hadoop/etc/hadoop/core-site.xml.template > hadoop/etc/hadoop/core-site.xml
sed s/HOSTNAME/localhost/ hadoop/etc/hadoop/yarn-site.xml.template > hadoop/etc/hadoop/yarn-site.xml
sed s/HOSTNAME/localhost/ hadoop/etc/hadoop/mapred-site.xml.template > hadoop/etc/hadoop/mapred-site.xml
chmod 755 hadoop/etc/hadoop/hadoop-env.sh

# spark
cp conf/spark/* spark/conf/

# hive
cp conf/hive/* hive/conf/
echo "export HADOOP_HOME=/apache/hadoop" >> hive/conf/hive-env.sh
sed s/HOSTNAME/localhost/ hive/conf/hive-site.xml.template > hive/conf/hive-site.xml

# livy
cp conf/livy/* livy/conf/
mkdir livy/logs
