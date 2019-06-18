#!/bin/bash

$HADOOP_HOME/etc/hadoop/hadoop-env.sh
rm /apache/pids/*

cd $HADOOP_HOME/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

find /var/lib/mysql -type f -exec touch {} \; && service mysql start

echo $S3_ACCESS_KEY_ID
echo $S3_ACCESS_SECRET_KEY
echo HOSTNAME = $HOSTNAME

# core-site.xml
cat $HADOOP_HOME/etc/hadoop/core-site.xml.template \
    | sed "s/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY_ID/g" \
    | sed "s/S3_ACCESS_SECRET_KEY/$S3_ACCESS_SECRET_KEY/g" \
    | sed "s/HOSTNAME/$HOSTNAME/g" \
    > $HADOOP_HOME/etc/hadoop/core-site.xml

# yarn-site.xml
sed "s/HOSTNAME/$HOSTNAME/g" $HADOOP_HOME/etc/hadoop/yarn-site.xml.template > $HADOOP_HOME/etc/hadoop/yarn-site.xml

# mapred-site.xml
cat $HADOOP_HOME/etc/hadoop/mapred-site.xml.template \
    | sed "s/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY_ID/g" \
    | sed "s/S3_ACCESS_SECRET_KEY/$S3_ACCESS_SECRET_KEY/g" \
    | sed "s/HOSTNAME/$HOSTNAME/g" \
    > $HADOOP_HOME/etc/hadoop/mapred-site.xml

# hdfs-site.xml
cat $HADOOP_HOME/etc/hadoop/hdfs-site.xml.template \
    | sed "s/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY_ID/g" \
    | sed "s/S3_ACCESS_SECRET_KEY/$S3_ACCESS_SECRET_KEY/g" \
    > $HADOOP_HOME/etc/hadoop/hdfs-site.xml

# hive-site.xml
cat $HIVE_HOME/conf/hive-site.xml.template \
    | sed "s/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY_ID/g" \
    | sed "s/S3_ACCESS_SECRET_KEY/$S3_ACCESS_SECRET_KEY/g" \
    | sed "s/HOSTNAME/$HOSTNAME/g" \
    > $HIVE_HOME/conf/hive-site.xml

/etc/init.d/ssh start

start-dfs.sh
start-yarn.sh
mr-jobhistory-daemon.sh start historyserver

$HADOOP_HOME/bin/hdfs dfsadmin -safemode leave


hadoop fs -mkdir -p /home/spark_conf
hadoop fs -put $HIVE_HOME/conf/hive-site.xml /home/spark_conf/
echo "spark.yarn.dist.files		hdfs:///home/spark_conf/hive-site.xml" >> $SPARK_HOME/conf/spark-defaults.conf

cp $HIVE_HOME/conf/hive-site.xml $SPARK_HOME/conf/


$SPARK_HOME/sbin/start-all.sh

nohup hiveserver2 --service metastore > metastore.log &

nohup livy-server > livy.log &

# griffin dir
hadoop fs -mkdir /griffin
hadoop fs -mkdir /griffin/json
hadoop fs -mkdir /griffin/persist
hadoop fs -mkdir /griffin/checkpoint

hadoop fs -mkdir /griffin/data
hadoop fs -mkdir /griffin/data/batch



# measure file
hadoop fs -put /root/measure/griffin-measure.jar /griffin/


# service
cat /root/service/config/application.properties.template \
    | sed "s|ES_HOSTNAME|$ES_URL|g" \
    | sed "s|POSTGRESQL_HOSTNAME|$POSTGRESQL_HOSTNAME|g" \
    | sed "s|HOSTNAME|$HOSTNAME|g" \
    > /root/service/config/application.properties

# json
sed "s|ENV_ES_URL|$ENV_ES_URL|g" /root/json/env.json.template > /root/json/env.json
cp /root/json/env.json /root/service/config/env_batch.json
hadoop fs -put json/*.json /griffin/json/

cd /root/service
nohup java -jar -Xmx1500m service.jar > service.log &
cd /root

/bin/bash -c "bash"
