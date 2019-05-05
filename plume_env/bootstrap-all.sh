#!/bin/bash

$HADOOP_HOME/etc/hadoop/hadoop-env.sh
rm /apache/pids/*

cd $HADOOP_HOME/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

find /var/lib/mysql -type f -exec touch {} \; && service mysql start
/etc/init.d/postgresql start

sed s/HOSTNAME/$HOSTNAME/ $HADOOP_HOME/etc/hadoop/core-site.xml.template > $HADOOP_HOME/etc/hadoop/core-site.xml
sed s/HOSTNAME/$HOSTNAME/ $HADOOP_HOME/etc/hadoop/yarn-site.xml.template > $HADOOP_HOME/etc/hadoop/yarn-site.xml
sed s/HOSTNAME/$HOSTNAME/ $HADOOP_HOME/etc/hadoop/mapred-site.xml.template > $HADOOP_HOME/etc/hadoop/mapred-site.xml

sed s/HOSTNAME/$HOSTNAME/ $HIVE_HOME/conf/hive-site.xml.template > $HIVE_HOME/conf/hive-site.xml

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

#hadoop fs -mkdir /griffin
#hadoop fs -mkdir /griffin/json
#hadoop fs -mkdir /griffin/persist
#hadoop fs -mkdir /griffin/checkpoint

#hadoop fs -mkdir /griffin/data
#hadoop fs -mkdir /griffin/data/batch

#measure file
hadoop fs -put measure/griffin-measure.jar /griffin/


#service
sed s/ES_HOSTNAME/$ES_HOSTNAME/ /root/service/config/application.properties.template > /root/service/config/application.properties_temp
sed s/HOSTNAME/$HOSTNAME/ /root/service/config/application.properties_temp > /root/service/config/application.properties
rm /root/service/config/application.properties_temp

#json
hadoop fs -put json/*.json /griffin/json/

cd /root/service
nohup java -jar service.jar > service.log &
cd /root

/bin/bash -c "bash"
