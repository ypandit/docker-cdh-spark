## Docker container with CDH-5.x.x & multiple versions of Apache Spark

### Installed software;

* cdh = 5.3.0
   * hive = 0.13.0
   * hadoop = 2.6.0
* spark = 1.3.1, 1.4.1, 1.5.0, master
* thrift = 0.9.0
* protobuf = 2.6.0
* maven = 3.3.3

By default, `SPARK_HOME=/usr/lib/spark/1.5.0`

### How to use?

```bash
docker pull ypandit/cdh-spark
docker run -it ypandit/cdh-spark /bin/bash
```
