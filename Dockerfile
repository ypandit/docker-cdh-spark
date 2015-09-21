FROM ypandit/centos6-java7
MAINTAINER Yogesh Pandit

ADD scripts/* /tmp/

RUN sed -i "s/^enabled=1$/enabled=0/" /etc/yum/pluginconf.d/fastestmirror.conf

# Install prerequisites
RUN yum clean all; yum install -y autoconf automake curl epel-release gcc-c++ git htop libevent-devel libtool libxml2-devel libxslt-devel m4 mysql-devel perl python-devel sqlite-devel

# Passwordless SSH
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key; ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key; ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa; cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

# CDH-5.x.x
RUN wget archive.cloudera.com/cdh5/one-click-install/redhat/6/x86_64/cloudera-cdh-5-0.x86_64.rpm; rpm -i cloudera-cdh-5-0.x86_64.rpm; rm cloudera-cdh-5-0.x86_64.rpm; rpm --import http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera; yum install -y hadoop hadoop-client hadoop-hdfs-namenode hadoop-hdfs-secondarynamenode hadoop-hdfs-datanode hive hive-metastore

RUN yum update -y libselinux

ENV HADOOP_CONF_DIR /etc/hadoop/conf
ENV HADOOP_HOME /usr/lib/hadoop
ENV HADOOP_PREFIX /usr/lib/hadoop
ENV HIVE_CONF_DIR /etc/hive/conf

ENV SPARK_VERSIONS 1.3.1;1.4.1;1.5.0;master

RUN bash /tmp/install.sh; sh /tmp/configure.sh; rm /tmp/install.sh; rm /tmp/configure.sh

ENV SPARK_HOME /usr/lib/spark/1.5.0
