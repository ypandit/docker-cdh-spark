#!/bin/bash

configure_hadoop() {
  echo "Configuring Hadoop. Creating required directories"
  mkdir -p /dfs/{nn,snn,dn};
  chown -R hdfs:hadoop /dfs;
  chmod -R 755 /dfs;
  echo "Hadoop configuration complete"
}

configure_hive_metastore() {
  echo "Configuring hive-metastore for hive-0.13.0"
  service mysqld restart

  mysql -uroot -e "USE mysql; CREATE DATABASE IF NOT EXISTS hive; GRANT ALL ON hive.* TO 'hive'@'localhost' IDENTIFIED BY 'hive'; FLUSH PRIVILEGES;"

  if [ -f /usr/lib/hive/scripts/metastore/upgrade/mysql/hive-schema-0.13.0.mysql.sql ]; then
    mysql -uhive -D hive -phive < /usr/lib/hive/scripts/metastore/upgrade/mysql/hive-schema-0.13.0.mysql.sql
  else
    echo "hive may not have been installed"
    exit 1
  fi
  echo "hive-metastore has been configured with hive-0.13.0 schema"
}

configure_hadoop
configure_hive_metastore