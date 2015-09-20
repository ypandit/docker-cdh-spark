FROM centos:centos6
MAINTAINER Yogesh Pandit

ADD scripts/* /tmp/

RUN sed -i "s/^enabled=1$/enabled=0/" /etc/yum/pluginconf.d/fastestmirror.conf

# Install prerequisites
RUN yum clean all; yum install -y autoconf automake curl epel-release gcc-c++ git htop libevent-devel libtool libxml2-devel libxslt-devel m4 mysql mysql-connector-java mysql-devel mysql-server openldap-clients openldap-servers openssh-clients openssh-server openssl openssl-devel perl python-devel sqlite-devel sudo tar vim wget which

RUN wget nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm; rpm -i nginx-release-centos-6-0.el6.ngx.noarch.rpm; rm nginx-release-centos-6-0.el6.ngx.noarch.rpm; yum install -y nginx

# Passwordless SSH
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key; ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key; ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa; cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

# Install Java
ENV JAVA_HOME /usr/java/latest
RUN cd /tmp; wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm; rpm -Uh /tmp/jdk-7u79-linux-x64.rpm; rm /tmp/jdk-7u79-linux-x64.rpm

RUN update-alternatives --install "/usr/bin/java" "java" "${JAVA_HOME}/bin/java" 1 && \
    update-alternatives --install "/usr/bin/javaws" "javaws" "${JAVA_HOME}/bin/javaws" 1 && \
    update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac" 1 && \
    update-alternatives --set java "${JAVA_HOME}/bin/java" && \
    update-alternatives --set javaws "${JAVA_HOME}/bin/javaws" && \
    update-alternatives --set javac "${JAVA_HOME}/bin/javac"

# Set JAVA_HOME and PATH
ENV PATH $JAVA_HOME/bin:$PATH
RUN echo -e "export JAVA_HOME=/usr/java/latest\nexport PATH=$JAVA_HOME/bin:$PATH" > /etc/profile.d/java.sh; source /etc/profile.d/java.sh

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
