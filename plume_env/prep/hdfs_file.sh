#!/bin/bash

# spark dir
hadoop fs -mkdir -p /home/spark_lib
hadoop fs -put $SPARK_HOME/jars/* /home/spark_lib/

# yarn dir
hadoop fs -mkdir -p /yarn-logs/logs
hadoop fs -chmod g+w /yarn-logs/logs

# hive dir
hadoop fs -mkdir /tmp
hadoop fs -mkdir /user
hadoop fs -mkdir /user/hive
hadoop fs -mkdir /user/hive/warehouse
hadoop fs -chmod g+w /tmp
hadoop fs -chmod g+w /user/hive/warehouse


# mongo jars
echo hadoop fs -put $MONGO_HOME/* /home/spark_lib/
#hadoop fs -put $MONGO_HOME/* /home/spark_lib/

# aws s3 jars
echo hadoop fs -put $HADOOP_AWS_HOME/* /home/spark_lib/
#hadoop fs -put $HADOOP_AWS_HOME/* /home/spark_lib/

# avro
wget http://central.maven.org/maven2/com/databricks/spark-avro_2.11/4.0.0/spark-avro_2.11-4.0.0.jar
hadoop fs -put spark-avro_2.11-4.0.0.jar /home/spark_lib/
rm spark-avro_2.11-4.0.0.jar




#measure file
#hadoop fs -put measure/griffin-measure.jar /griffin/


