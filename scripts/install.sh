#!/bin/bash

declare -A sparks

sparks["1.3.1"]="https://github.com/apache/spark/archive/v1.3.1.tar.gz"
sparks["1.4.1"]="https://github.com/apache/spark/archive/v1.4.1.tar.gz"
sparks["1.5.0"]="https://github.com/apache/spark/archive/v1.5.0.tar.gz"
sparks["master"]="https://github.com/apache/spark/archive/master.tar.gz"

# Install thrift-0.9.0
install_thrift() {
  echo "Installing thrift-0.9.0"
  cd /tmp; wget http://archive.apache.org/dist/thrift/0.9.0/thrift-0.9.0.tar.gz; tar zxf thrift-0.9.0.tar.gz
  cd /tmp/thrift-0.9.0; ./configure --with-lua=no; make; make install
  echo "Installation of thrift-0.9.0 complete"
}

# Install protobuf-2.6.0
install_protobuf() {
  echo "Installing protobuf-2.6.0"
  cd /tmp; wget https://github.com/google/protobuf/releases/download/v2.6.0/protobuf-2.6.0.tar.gz; tar -zxvf protobuf-2.6.0.tar.gz
  cd /tmp/protobuf-2.6.0; ./autogen.sh; ./configure --prefix=/usr; make; make check; make install
  echo "Installation of protobuf-2.6.0 complete"
}

# Build apache-spark
build_spark() {
  url=$1
  version=$2
  echo "Building Apache Spark $version from source - $url"

  if [ ! -d /tmp/spark ]; then
    mkdir /tmp/spark
  fi

  if [ ! -f /tmp/spark-${version}.tar.gz ]; then
    cd /tmp; wget -O spark-${version}.tar.gz $url; tar -zxf spark-${version}.tar.gz -C /tmp/spark
  fi

  if [ -d /tmp/spark/spark-${version} ]; then
    echo "Building spark-${version} with support for hive & thriftserver"

    cp /tmp/make-distribution.sh /tmp/spark/spark-${version}; cd /tmp/spark/spark-${version};
    export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"
    ./make-distribution.sh --tgz --mvn /usr/local/maven/bin/mvn -DskipTests -Phadoop-2.4 -Dhadoop.version=2.6.0 -Phive -Phive-thriftserver

    if [ -e /tmp/spark/spark-${version}/spark-*.tgz ]; then
      mversion=$(ls /tmp/spark/spark-${version} | grep spark-*.tgz | cut -d'-' -f2)
      echo "Building of Apache Spark ${mversion} complete"
      cd /tmp/spark/spark-${version} && tar zxf spark-*.tgz -C /usr/lib/spark && mv /usr/lib/spark/spark-* /usr/lib/spark/${mversion}
      rm -rf /tmp/spark /tmp/spark-${version}.tar.gz
      echo "Apache Spark ${version} installed at /usr/lib/spark/${mversion}"
    else
      echo "Building of Apache Spark $version failed"
      exit 1
    fi
  else
    echo "Apache Spark ${version} download did not work"
    exit 1
  fi
}

# Install apache-spark based on SPARK_VERSIONS env variable
install_spark() {
  if [ ! -d "/usr/lib/spark" ]; then
    mkdir /usr/lib/spark
  fi

  echo "Installing Apache Spark"
  SPARK_VERSIONS=$(env | grep 'SPARK_VERSIONS' | cut -d'=' -f 2)
  for version in $(echo $SPARK_VERSIONS | tr ";" "\n"); do
    build_spark ${sparks[$version]} $version
    echo "Installation of Apache Spark $version complete"
  done

}

# Install apache-maven-3.3.3
install_maven() {
  echo "Installing Apache Maven 3.3.3"
  wget -O /tmp/maven.tgz mirrors.sonic.net/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz
  mkdir -p /usr/local/maven; tar vxzf /tmp/maven.tgz -C /usr/local/maven; mv /usr/local/maven/apache-maven-3.3.3/* /usr/local/maven/; rm -rf /usr/local/maven/apache-maven-3.3.3; rm /tmp/maven.tgz

  if [ -f /usr/local/maven/bin/mvn ]; then
    echo -e "export M2_HOME=/usr/local/maven\nexport PATH=$M2_HOME/bin:$PATH" > /etc/profile.d/maven.sh
    source /etc/profile.d/maven.sh
    if [ -f /tmp/settings.xml ]; then
      mkdir -p /root/.m2; mv /tmp/settings.xml /root/.m2/
    fi
    echo 'Installation of Apache Maven 3.3.3 complete.'
  else
    echo "Installation of Apache Maven failed"
    exit 1
  fi
}

install_maven
install_protobuf
install_thrift
install_spark
