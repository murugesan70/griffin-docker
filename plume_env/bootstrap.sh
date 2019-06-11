#!/bin/bash

$HADOOP_HOME/etc/hadoop/hadoop-env.sh
#rm /apache/pids/*

cd $HADOOP_HOME/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

find /var/lib/mysql -type f -exec touch {} \; && service mysql start

#echo $S3_ACCESS_KEY_ID
#echo $S3_ACCESS_SECRET_KEY
#echo HOSTNAME = $HOSTNAME
#sed  "s/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY_ID/g"  $HADOOP_HOME/etc/hadoop/core-site.xml.template  >> $HADOOP_HOME/etc/hadoop/core-site.xml.template.bak
#sed  "s/S3_ACCESS_SECRET_KEY/$S3_ACCESS_SECRET_KEY/g" $HADOOP_HOME/etc/hadoop/core-site.xml.template.bak >> $HADOOP_HOME/etc/hadoop/core-site.xml.template.bak1
#sed s/HOSTNAME/$HOSTNAME/ $HADOOP_HOME/etc/hadoop/core-site.xml.template.bak1 > $HADOOP_HOME/etc/hadoop/core-site.xml.template
#sed s/HOSTNAME/$HOSTNAME/ $HADOOP_HOME/etc/hadoop/yarn-site.xml.template > $HADOOP_HOME/etc/hadoop/yarn-site.xml
#sed  "s/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY_ID/g"  $HADOOP_HOME/etc/hadoop/mapred-site.xml.template  >> $HADOOP_HOME/etc/hadoop/mapred-site.xml.template.bak
#sed  "s/S3_ACCESS_SECRET_KEY/$S3_ACCESS_SECRET_KEY/g" $HADOOP_HOME/etc/hadoop/mapred-site.xml.template.bak >> $HADOOP_HOME/etc/hadoop/mapred-site.xml.template.bak1
#sed s/HOSTNAME/$HOSTNAME/ $HADOOP_HOME/etc/hadoop/mapred-site.xml.template.bak1 > $HADOOP_HOME/etc/hadoop/mapred-site.xml.template
#
#sed  "s/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY_ID/g"  $HADOOP_HOME/etc/hadoop/hdfs-site.xml  >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml.bak
#sed  "s/S3_ACCESS_SECRET_KEY/$S3_ACCESS_SECRET_KEY/g" $HADOOP_HOME/etc/hadoop/hdfs-site.xml.bak > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
#sed  "s/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY_ID/g"  $HIVE_HOME/conf/hive-site.xml.template  >> $HIVE_HOME/conf/hive-site.xml.template.bak
#sed  "s/S3_ACCESS_SECRET_KEY/$S3_ACCESS_SECRET_KEY/g" $HIVE_HOME/conf/hive-site.xml.template.bak  > $HIVE_HOME/conf/hive-site.xml.template.bak1
#sed s/HOSTNAME/$HOSTNAME/ $HIVE_HOME/conf/hive-site.xml.template.bak1 > $HIVE_HOME/conf/hive-site.xml.template

/etc/init.d/ssh start

start-dfs.sh
start-yarn.sh
mr-jobhistory-daemon.sh start historyserver

$HADOOP_HOME/bin/hdfs dfsadmin -safemode leave

#sleep 5

/bin/bash -c "bash"
