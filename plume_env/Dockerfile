FROM ubuntu:16.04
MAINTAINER org.apache.griffin

# install wget, ssh, unzip...
RUN apt-get update \
    && apt-get install wget -y \
    && apt-get install openssh-client openssh-server -y \
    && apt-get install unzip curl -y \
    && apt-get install vim -y \
    && apt-get install net-tools -y \
    && apt-get install awscli -y

# install mysql
RUN DEBIAN_FRONTEND=noninteractive apt-get install mysql-server -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install libmysql-java -y

# ARGs
ARG ENV_POSTGRESQL_HOSTNAME
ARG ENV_ES_URL
ARG ENV_S3_ACCESS_KEY
ARG ENV_S3_SECRET_KEY

# make apache dir
RUN mkdir /apache 
WORKDIR /apache

# copy scripts and configs
ADD prep /apache
ADD conf /apache/conf

EXPOSE 2122

# ssh-config
RUN ./ssh-config.sh

# ENVs
ENV POSTGRESQL_HOSTNAME $ENV_POSTGRESQL_HOSTNAME
ENV ES_URL $ENV_ES_URL
ENV S3_ACCESS_KEY_ID $ENV_S3_ACCESS_KEY
ENV AWS_ACCESS_KEY_ID $ENV_S3_ACCESS_KEY
ENV S3_ACCESS_SECRET_KEY $ENV_S3_SECRET_KEY
ENV AWS_SECRET_ACCESS_KEY $ENV_S3_SECRET_KEY

# software install
RUN ./software-install.sh
RUN ./dir.sh && ./software-config.sh

# ENVs
ENV JAVA_HOME /apache/jdk
ENV HADOOP_HOME /apache/hadoop
ENV MONGO_HOME /apache/mongodb
ENV HADOOP_AWS_HOME /apache/aws-sdk
ENV HADOOP_INSTALL $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV YARN_HOME $HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_HOME/lib/native
ENV SCALA_HOME /apache/scala
ENV SPARK_HOME /apache/spark
ENV HIVE_HOME /apache/hive
ENV HADOOP_USER_CLASSPATH_FIRST true
ENV LIVY_HOME /apache/livy

# create hdfs-site.xml.template
# necessary, if we want to replace S3_ACCESS_KEY_ID, S3_ACCESS_SECRET_KEY anytime later
RUN cp $HADOOP_HOME/etc/hadoop/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml.template

ENV PATH $JAVA_HOME/bin:$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SCALA_HOME/bin:$SPARK_HOME/bin:$HIVE_HOME/bin:$LIVY_HOME/bin

# expose ports
EXPOSE 3306
EXPOSE 9000 10020
EXPOSE 50010 50020 50070 50075 50090
EXPOSE 19888
EXPOSE 8030 8031 8032 8033 8040 8042 8088
EXPOSE 49707
EXPOSE 9083 27017 6066
EXPOSE 8080
EXPOSE 8998

# build/download griffin jars
RUN ./griffin-build.sh

# set mysql to hive
RUN ln -s /usr/share/java/mysql-connector-java.jar $HIVE_HOME/lib/mysql-connector-java.jar \
    && ln -s /usr/share/java/mysql.jar $HIVE_HOME/lib/mysql.jar

# init mysql
RUN cd /apache/conf/mysql \
    && cp bind_0.cnf /etc/mysql/conf.d/bind_0.cnf \
    && ./mysql-init.sh

# run bootstrap as root
USER root
WORKDIR /root

# add prep to root
# (used by bootstrap-all.sh)
ADD prep /root

# add bootstrap.sh
ADD bootstrap.sh /etc/
RUN chmod 755 /etc/bootstrap.sh

# initial
RUN hdfs namenode -format

# run bootstrap.sh
RUN /etc/bootstrap.sh \
    && /apache/hdfs_file.sh \
    && rm /apache/*.sh

#RUN chmod 755 prepare.sh
#RUN ./prepare.sh

# add bootstrap-all
ADD bootstrap-all.sh /etc/
RUN chmod 755 /etc/bootstrap-all.sh

ENTRYPOINT ["/etc/bootstrap-all.sh"]
