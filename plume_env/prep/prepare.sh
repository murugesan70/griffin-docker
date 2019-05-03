#!/bin/bash

hadoop fs -mkdir /griffin
hadoop fs -mkdir /griffin/json
hadoop fs -mkdir /griffin/persist
hadoop fs -mkdir /griffin/checkpoint

hadoop fs -mkdir /griffin/data
hadoop fs -mkdir /griffin/data/batch

#measure file
hadoop fs -put measure/griffin-measure.jar /griffin/

#data

#service
sed s/ES_HOSTNAME/$ES_HOSTNAME/ /root/service/config/application.properties.template > /root/service/config/application.properties
sed -i 's/HOSTNAME/$HOSTNAME/g' /root/service/config/application.properties

#json
hadoop fs -put json/*.json /griffin/json/
