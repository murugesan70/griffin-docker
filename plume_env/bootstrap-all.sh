#!/bin/bash
set -euo pipefail

$HADOOP_HOME/etc/hadoop/hadoop-env.sh
rm -f /apache/pids/*

find /var/lib/mysql -type f -exec touch {} \; && service mysql start

echo HOSTNAME = $HOSTNAME

# core-site.xml
cat $HADOOP_HOME/etc/hadoop/core-site.xml.template \
    | sed "s/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY_ID/g" \
    | sed "s/S3_ACCESS_SECRET_KEY/$S3_ACCESS_SECRET_KEY/g" \
    | sed "s/S3A_ENDPOINT/$S3A_ENDPOINT/g" \
    | sed "s/HOSTNAME/$HOSTNAME/g" \
    > $HADOOP_HOME/etc/hadoop/core-site.xml

# yarn-site.xml
cat $HADOOP_HOME/etc/hadoop/yarn-site.xml.template \
    | sed "s/HOSTNAME/$HOSTNAME/g" \
    | sed "s/YARN_NODEMANAGER_RESOURCE_MEMORY_MB/${YARN_NODEMANAGER_RESOURCE_MEMORY_MB:-8192}/g" \
    | sed "s/YARN_SCHEDULER_MAXIMUM_ALLOCATION_MB/${YARN_SCHEDULER_MAXIMUM_ALLOCATION_MB:-8192}/g" \
    > $HADOOP_HOME/etc/hadoop/yarn-site.xml

# mapred-site.xml
cat $HADOOP_HOME/etc/hadoop/mapred-site.xml.template \
    | sed "s/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY_ID/g" \
    | sed "s/S3_ACCESS_SECRET_KEY/$S3_ACCESS_SECRET_KEY/g" \
    | sed "s/S3A_ENDPOINT/$S3A_ENDPOINT/g" \
    | sed "s/HOSTNAME/$HOSTNAME/g" \
    > $HADOOP_HOME/etc/hadoop/mapred-site.xml

# hdfs-site.xml
cat $HADOOP_HOME/etc/hadoop/hdfs-site.xml.template \
    | sed "s/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY_ID/g" \
    | sed "s/S3_ACCESS_SECRET_KEY/$S3_ACCESS_SECRET_KEY/g" \
    | sed "s/S3A_ENDPOINT/$S3A_ENDPOINT/g" \
    > $HADOOP_HOME/etc/hadoop/hdfs-site.xml

# hive-site.xml
cat $HIVE_HOME/conf/hive-site.xml.template \
    | sed "s/S3_ACCESS_KEY_ID/$S3_ACCESS_KEY_ID/g" \
    | sed "s/S3_ACCESS_SECRET_KEY/$S3_ACCESS_SECRET_KEY/g" \
    | sed "s/S3A_ENDPOINT/$S3A_ENDPOINT/g" \
    | sed "s/HOSTNAME/$HOSTNAME/g" \
    > $HIVE_HOME/conf/hive-site.xml

# sparkProperties.json
if [[ ${SPARK_MASTER:-"yarn"} == "yarn" ]]; then
    cat /root/service/config/sparkPropertiesYarn.json.template \
        | sed "s/SPARK_NUM_EXECUTORS/${SPARK_NUM_EXECUTORS:-2}/g" \
        | sed "s/SPARK_EXECUTOR_CORES/${SPARK_EXECUTOR_CORES:-8}/g" \
        | sed "s/SPARK_DRIVER_MEMORY/${SPARK_DRIVER_MEMORY:-1g}/g" \
        | sed "s/SPARK_EXECUTOR_MEMORY/${SPARK_EXECUTOR_MEMORY:-1g}/g" \
    > /root/service/config/sparkProperties.json
else
    cat /root/service/config/sparkPropertiesKubernetes.json.template \
        | sed "s/SPARK_NUM_EXECUTORS/${SPARK_NUM_EXECUTORS:-2}/g" \
        | sed "s/SPARK_EXECUTOR_CORES/${SPARK_EXECUTOR_CORES:-8}/g" \
        | sed "s/SPARK_DRIVER_MEMORY/${SPARK_DRIVER_MEMORY:-1g}/g" \
        | sed "s/SPARK_EXECUTOR_MEMORY/${SPARK_EXECUTOR_MEMORY:-1g}/g" \
        | sed "s/SPARK_KUBERNETES_CONTAINER_IMAGE/${SPARK_KUBERNETES_CONTAINER_IMAGE}/g" \
        | sed "s/SPARK_KUBERNETES_NAMESPACE/${SPARK_KUBERNETES_NAMESPACE}/g" \
        | sed "s/SPARK_KUBERNETES_AUTHENTICATE_SERVICEACCOUNTNAME/${SPARK_KUBERNETES_AUTHENTICATE_SERVICEACCOUNTNAME}/g" \
        | sed "s/SPARK_KUBERNETES_AUTHENTICATE_OAUTHTOKEN/${SPARK_KUBERNETES_AUTHENTICATE_OAUTHTOKEN}/g" \
        | sed "s/SPARK_SQL_HIVE_METASTORE_VERSION/${SPARK_SQL_HIVE_METASTORE_VERSION}/g" \
        | sed "s/SPARK_SQL_HIVE_METASTORE_DBNAME/${SPARK_SQL_HIVE_METASTORE_DBNAME}/g" \
        | sed "s/SPARK_HADOOP_HIVE_METASTORE_URIS/${SPARK_HADOOP_HIVE_METASTORE_URIS}/g" \
        | sed "s/SPARK_HADOOP_FS_S3A_ACCESS_KEY/${SPARK_HADOOP_FS_S3A_ACCESS_KEY}/g" \
        | sed "s/SPARK_HADOOP_FS_S3A_SECRET_KEY/${SPARK_HADOOP_FS_S3A_SECRET_KEY}/g" \
        | sed "s/SPARK_HADOOP_FS_S3A_ENDPOINT/${SPARK_HADOOP_FS_S3A_ENDPOINT}/g" \
        | sed "s/SPARK_DRIVER_HOST/${SPARK_DRIVER_HOST}/g" \
        | sed "s/SPARK_DRIVER_BINDADDRESS/${SPARK_DRIVER_BINDADDRESS}/g" \
        | sed "s/SPARK_DRIVER_PORT/${SPARK_DRIVER_PORT}/g" \
        | sed "s/SPARK_BLOCKMANAGER_PORT/${SPARK_BLOCKMANAGER_PORT}/g" \
    > /root/service/config/sparkProperties.json
fi

/etc/init.d/ssh start

start-dfs.sh
start-yarn.sh
mr-jobhistory-daemon.sh start historyserver

$HADOOP_HOME/bin/hdfs dfsadmin -safemode leave

# put hive-site.xml to spark conf
cp $HIVE_HOME/conf/hive-site.xml $SPARK_HOME/conf/
# and distribute it to each executor
hadoop fs -mkdir -p /home/spark_conf
hadoop fs -put -f $HIVE_HOME/conf/hive-site.xml /home/spark_conf/
SPARK_YARN_DIST_FILES="spark.yarn.dist.files        hdfs:///home/spark_conf/hive-site.xml"
if ! grep -Fq "$SPARK_YARN_DIST_FILES" $SPARK_HOME/conf/spark-defaults.conf; then
    echo "$SPARK_YARN_DIST_FILES" >> $SPARK_HOME/conf/spark-defaults.conf
fi

# start spark
$SPARK_HOME/sbin/start-all.sh

# start hive
nohup hiveserver2 --service metastore > metastore.log &

# start livy
nohup livy-server > livy.log &

# griffin dir
hadoop fs -mkdir -p /griffin
hadoop fs -mkdir -p /griffin/json
hadoop fs -mkdir -p /griffin/persist
hadoop fs -mkdir -p /griffin/checkpoint
hadoop fs -mkdir -p /griffin/data
hadoop fs -mkdir -p /griffin/data/batch

# griffin measure
hadoop fs -put -f /root/measure/griffin-measure.jar /griffin/

# griffin service
cat /root/service/config/application.properties.template \
    | sed "s|ES_URL|${ES_URL#*//}|g" \
    | sed "s|POSTGRESQL_HOSTNAME|$POSTGRESQL_HOSTNAME|g" \
    | sed "s|HOSTNAME|$HOSTNAME|g" \
    | sed "s|GRIFFIN_LOGIN_STRATEGY|${GRIFFIN_LOGIN_STRATEGY:-default}|g" \
    | sed "s|GRIFFIN_LDAP_URL|${GRIFFIN_LDAP_URL:-}|g" \
    | sed "s|GRIFFIN_LDAP_EMAIL|${GRIFFIN_LDAP_EMAIL:-}|g" \
    | sed "s|GRIFFIN_LDAP_USER_SEARCH_BASE|${GRIFFIN_LDAP_USER_SEARCH_BASE:-}|g" \
    | sed "s|GRIFFIN_LDAP_USER_SEARCH_PATTERN|${GRIFFIN_LDAP_USER_SEARCH_PATTERN:-}|g" \
    | sed "s|GRIFFIN_LDAP_GROUP_SEARCH_BASE|${GRIFFIN_LDAP_GROUP_SEARCH_BASE:-}|g" \
    | sed "s|GRIFFIN_LDAP_GROUP_SEARCH_PATTERN|${GRIFFIN_LDAP_GROUP_SEARCH_PATTERN:-}|g" \
    | sed "s|GRIFFIN_LDAP_BINDDN|${GRIFFIN_LDAP_BINDDN:-}|g" \
    | sed "s|GRIFFIN_LDAP_BINDPASSWORD|${GRIFFIN_LDAP_BINDPASSWORD:-}|g" \
    | sed "s|PLUME_KEY_STORE|${PLUME_KEY_STORE:-}|g" \
    | sed "s|PLUME_KEY_PASSWORD|${PLUME_KEY_PASSWORD:-}|g" \
    | sed "s|LIVY_NEED_QUEUE|${LIVY_NEED_QUEUE:-true}|g" \
    | sed "s|LIVY_TASK_MAX_CONCURRENT_COUNT|${LIVY_TASK_MAX_CONCURRENT_COUNT:-100}|g" \
    | sed "s|LIVY_TASK_SUBMIT_INTERVAL_SECOND|${LIVY_TASK_SUBMIT_INTERVAL_SECOND:-3}|g" \
    | sed "s|LIVY_TASK_APPID_RETRY_COUNT|${LIVY_TASK_APPID_RETRY_COUNT:-3}|g" \
    > /root/service/config/application.properties


# griffin env
sed "s|ES_URL|$ES_URL|g" /root/json/env.json.template > /root/json/env.json
cp /root/json/env.json /root/service/config/env_batch.json
hadoop fs -put -f /root/json/*.json /griffin/json/

# start griffin service
cd /root/service
nohup java -jar -Xmx1500m service.jar > service.log &

# workdir
cd /root

# keeps container running
/bin/bash
