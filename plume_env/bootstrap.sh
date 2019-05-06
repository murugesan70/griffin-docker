#!/bin/bash

$HADOOP_HOME/etc/hadoop/hadoop-env.sh
#rm /apache/pids/*

cd $HADOOP_HOME/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

find /var/lib/mysql -type f -exec touch {} \; && service mysql start

echo sed -i 's/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY/g'  $HADOOP_HOME/etc/hadoop/core-site.xml.template 
sed -i 's/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY/g'  $HADOOP_HOME/etc/hadoop/core-site.xml.template 
sed -i 's/S3_ACCESS_SECRET_KEY/$S3_SECRET_KEY/g' $HADOOP_HOME/etc/hadoop/core-site.xml.template
sed s/HOSTNAME/$HOSTNAME/ $HADOOP_HOME/etc/hadoop/core-site.xml.template > $HADOOP_HOME/etc/hadoop/core-site.xml
sed s/HOSTNAME/$HOSTNAME/ $HADOOP_HOME/etc/hadoop/yarn-site.xml.template > $HADOOP_HOME/etc/hadoop/yarn-site.xml
sed -i 's/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY/g'  $HADOOP_HOME/etc/hadoop/mapred-site.xml.template 
sed -i 's/S3_ACCESS_SECRET_KEY/$S3_SECRET_KEY/g' $HADOOP_HOME/etc/hadoop/mapred-site.xml.template
sed s/HOSTNAME/$HOSTNAME/ $HADOOP_HOME/etc/hadoop/mapred-site.xml.template > $HADOOP_HOME/etc/hadoop/mapred-site.xml

sed -i 's/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY/g'  $HADOOP_HOME/etc/hadoop/hdfs-site.xml
sed -i 's/S3_ACCESS_SECRET_KEY/$S3_SECRET_KEY/g' $HADOOP_HOME/etc/hadoop/hdfs-site.xml
sed -i 's/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY/g'  $HIVE_HOME/conf/hive-site.xml.template 
sed -i 's/S3_ACCESS_SECRET_KEY/$S3_SECRET_KEY/g' $HIVE_HOME/conf/hive-site.xml.template 
sed s/HOSTNAME/$HOSTNAME/ $HIVE_HOME/conf/hive-site.xml.template > $HIVE_HOME/conf/hive-site.xml

/etc/init.d/ssh start

start-dfs.sh
start-yarn.sh
mr-jobhistory-daemon.sh start historyserver

$HADOOP_HOME/bin/hdfs dfsadmin -safemode leave

sleep 5

/bin/bash -c "bash"
