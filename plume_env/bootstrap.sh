#!/bin/bash

$HADOOP_HOME/etc/hadoop/hadoop-env.sh
rm /apache/pids/*

cd $HADOOP_HOME/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

find /var/lib/mysql -type f -exec touch {} \; && service mysql start

sed -i 's/S3_ACCESS_KEY_ID/AKIAJ2VPXWB7KOWSEWLA/g'  $HADOOP_HOME/etc/hadoop/core-site.xml.template 
sed -i 's/S3_ACCESS_SECRET_KEY/ILa3881llPSSQDelz22G94IeHvUqooYC8JOYGVN0/g' $HADOOP_HOME/etc/hadoop/core-site.xml.template
sed s/HOSTNAME/$HOSTNAME/ $HADOOP_HOME/etc/hadoop/core-site.xml.template > $HADOOP_HOME/etc/hadoop/core-site.xml
sed s/HOSTNAME/$HOSTNAME/ $HADOOP_HOME/etc/hadoop/yarn-site.xml.template > $HADOOP_HOME/etc/hadoop/yarn-site.xml
sed -i 's/S3_ACCESS_KEY_ID/AKIAJ2VPXWB7KOWSEWLA/g'  $HADOOP_HOME/etc/hadoop/mapred-site.xml.template 
sed -i 's/S3_ACCESS_SECRET_KEY/ILa3881llPSSQDelz22G94IeHvUqooYC8JOYGVN0/g' $HADOOP_HOME/etc/hadoop/mapred-site.xml.template
sed s/HOSTNAME/$HOSTNAME/ $HADOOP_HOME/etc/hadoop/mapred-site.xml.template > $HADOOP_HOME/etc/hadoop/mapred-site.xml

sed -i 's/S3_ACCESS_KEY_ID/AKIAJ2VPXWB7KOWSEWLA/g'  $HADOOP_HOME/etc/hadoop/hdfs-site.xml
sed -i 's/S3_ACCESS_SECRET_KEY/ILa3881llPSSQDelz22G94IeHvUqooYC8JOYGVN0/g' $HADOOP_HOME/etc/hadoop/hdfs-site.xml
sed -i 's/S3_ACCESS_KEY_ID/AKIAJ2VPXWB7KOWSEWLA/g'  $HIVE_HOME/conf/hive-site.xml.template 
sed -i 's/S3_ACCESS_SECRET_KEY/ILa3881llPSSQDelz22G94IeHvUqooYC8JOYGVN0/g' $HIVE_HOME/conf/hive-site.xml.template 
sed s/HOSTNAME/$HOSTNAME/ $HIVE_HOME/conf/hive-site.xml.template > $HIVE_HOME/conf/hive-site.xml

/etc/init.d/ssh start

start-dfs.sh
start-yarn.sh
mr-jobhistory-daemon.sh start historyserver

$HADOOP_HOME/bin/hdfs dfsadmin -safemode leave


/bin/bash -c "bash"
