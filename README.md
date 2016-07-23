# WIP

This is the very first draft, which is a *work in progress*. The implementation is *incomplete* and subject to change. The documentation can be inaccurate.

# Intro

Apache Drill is a very flexible and powerful SQL-like query engine that allows to query many different data-sources, not only RDBMSs but also JSON and CSV files, `MongoDB`, `HBase`, `Hive`, etc. (Consult here [https://drill.apache.org/docs/query-data-introduction/](https://drill.apache.org/docs/query-data-introduction/) for the current list of possible data-sources.) Hence, it is not only useful for ad-hoc queries, but also for ETL jobs.

# How to Install

Download the Apache Drill tar-ball from [https://drill.apache.org/download/](https://drill.apache.org/download/) and then untar it in some location, like:

        tar xf apache-drill-1.7.0.tar.gz

At [https://github.com/apache/drill/blob/master/INSTALL.md](https://github.com/apache/drill/blob/master/INSTALL.md) there are more details on how to build, customize, and install it.

# How to Run the Drill Shell in Embedded Mode

Go to the base directory where the tar-ball was extracted, and either run:

        bin/drill-embedded

or:

        bin/sqlline -u jdbc:drill:zk=local

It will load:

        apache drill 1.7.0
        "what ever the mind of man can conceive and believe, drill can query"
        0: jdbc:drill:zk=local>

The `./log/sqlline.log` log file contains the operational log of Apache Drill. The `./log/sqlline_queries.json` log file contains JSON lines with each SQL instruction that has been sent for execution to Drill, with its `queryId`, database `schema`, the SQL instruction itself in the `queryText`, the `start` and `finish` epoch times of the SQL instruction in milliseconds resolution, the `outcome` of the instruction, either completed or failed, the `username` who submitted it and the client `remoteAddress`. These log files are located by default under the base directory where the tar-ball was extracted.

The list of commands directly for the Drill Shell (ie., not the SQL-alike commands) is available at [https://drill.apache.org/docs/configuring-the-drill-shell/](https://drill.apache.org/docs/configuring-the-drill-shell/). For example, if after some window of inactivity the Drill Shell loses connectivity to Drillbit, showing a message like:

        Error: SYSTEM ERROR: IllegalArgumentException: Attempted to send a message when connection is no longer valid.

        Query submission to Drillbit failed.

you can reconnect your shell session to Drillbit using:

        0: jdbc:drill:zk=local> !reconnect jdbc:drill:drillbit=localhost

To start Drill in distributed mode, consult [https://drill.apache.org/docs/starting-drill-in-distributed-mode/](https://drill.apache.org/docs/starting-drill-in-distributed-mode/). The internal implementation of a distributed Drill is explained at [http://drill.apache.org/docs/drill-query-execution/](http://drill.apache.org/docs/drill-query-execution/).

# Some SQL-alike commands:

A very simple query on a JSON file could be:

        0: jdbc:drill:zk=local> SELECT * FROM dfs.`<local-filesystem-path-to>/a_json_file.json` LIMIT 5 ;

At [https://drill.apache.org/docs/json-data-model/](https://drill.apache.org/docs/json-data-model/) there are more examples and guides on how to query JSON data. For example, and citing from this document (*[quotes]* in brackets are summaries for here, you should consult this document):

- *By default, Drill does not support JSON lists [whose elements are] of different types.* [How to alter this default and other workarounds are shown. In short, Drill is, _by default_, stronger typed than JSON, which of course isn't typed at all.]

- *The Union type allows storing different types in the same field.*

- *Drill returns null when a document does not have the specified map or level.* [For example, the case where some JSON paths have some maps or levels but other JSON paths in the same document don't have them.]

- How to use the FLATTEN and KVGEN functions.

- Other very instructive examples.

Here it is shown an example querying JSON data, using also the [Drill-GIS plugin](https://github.com/k255/drill-gis), in the script [query_LosAngelesMetro_NextBus_vehicle_positions.sh](query_LosAngelesMetro_NextBus_vehicle_positions.sh). The associated, external SQL file [query_LosAngelesMetro_NextBus_vehicle_positions.sql](query_LosAngelesMetro_NextBus_vehicle_positions.sql) has two queries which give results like the ones below (the data from http://restbus.info/ is real-time, so there results probably vary in another run), plus an ETL job on the data which creates a transformed and filtered JSON file from the original:

         +---------------------------------------------------------+----------+--------------+----------+------+-------------+--------------+------------------+
         |                        vehicles                         | routeId  | directionId  | heading  | kph  |     lat     |     lon      | secsSinceReport  |
         +---------------------------------------------------------+----------+--------------+----------+------+-------------+--------------+------------------+
         | http://restbus.info/api/agencies/lametro/vehicles/6059  | 20       | 20_482_0     | 75       | 27   | 34.061691   | -118.307037  | 246              |
         | http://restbus.info/api/agencies/lametro/vehicles/8557  | 16       | 16_281_1     | 270      | 31   | 34.073627   | -118.382523  | 246              |
         | http://restbus.info/api/agencies/lametro/vehicles/3919  | 460      | 460_173_0    | 165      | 48   | 33.900269   | -118.046715  | 246              |
         | http://restbus.info/api/agencies/lametro/vehicles/4003  | 52       | 52_234_0     | 220      | 0    | 33.869247   | -118.287338  | 246              |
         | http://restbus.info/api/agencies/lametro/vehicles/5841  | 20       | 20_479_0     | 220      | 0    | 34.058586   | -118.44532   | 246              |
         ...
         +----------+--------------+--------------------------+---------------------+
         | routeId  | directionId  | numBusesInThisDirection  |     avgSpeedKpH     |
         +----------+--------------+--------------------------+---------------------+
         | 40       | 40_859_1     | 1                        | 53.0                |
         | 40       | 40_833_0     | 1                        | 50.0                |
         | 33       | 33_357_0     | 1                        | 48.0                |
         | 204      | 204_106_1    | 1                        | 47.0                |
         | 705      | 705_66_0     | 1                        | 47.0                |
         | 45       | 45_474_1     | 1                        | 47.0                |
         | 33       | 33_352_0     | 1                        | 43.0                |
         ...

To query CSV files using Drill's SQL is similar, just that the columns are referenced by the names `COLUMNS[n]`, where `n` is the 0-based index of the column in the CSV, and the name of the SQL table (or view) in the FROM clause is the pathname of the CSV file. ([http://drill.apache.org/docs/querying-plain-text-files/](http://drill.apache.org/docs/querying-plain-text-files/) has the formal details.)

( ... TODO: more SQL-like commands to put here, and examples of storage plugin configurations ... )

The formal list of ANSI SQL commands supported by Drill is at [https://drill.apache.org/docs/sql-reference-introduction/](https://drill.apache.org/docs/sql-reference-introduction/).

E.g., to view the system's options (settings), use its SQL-alike commands:

        0: jdbc:drill:zk=local> DESCRIBE sys.options;

        0: jdbc:drill:zk=local> SELECT name, type, status, bool_val, num_val, float_val, string_val FROM sys.options ORDER BY name;
        +--------------------------------------------------------------------+---------+----------+-------------+-----------------------+
        |                                name                                |  type   |  status  |   num_val   |      string_val       |
        +--------------------------------------------------------------------+---------+----------+-------------+-----------------------+
        | drill.exec.functions.cast_empty_string_to_null                     | SYSTEM  | DEFAULT  | null        | null                  |
        | drill.exec.storage.file.partition.column.label                     | SYSTEM  | DEFAULT  | null        | dir                   |
        | drill.exec.storage.implicit.filename.column.label                  | SYSTEM  | DEFAULT  | null        | filename              |
        | drill.exec.storage.implicit.filepath.column.label                  | SYSTEM  | DEFAULT  | null        | filepath              |
        ...
        88 rows selected (0.112 seconds)

# Apache Drill's HTTP interface (Web Console)

Instead of using the command-line oriented Drill Shell, an HTTP interface is also active, which is very easy and intuitive. The Drill Web Console listens by default at port tcp/8047. For example, to submit SQL-like queries, go to (supposing it is running locally):

        http://localhost:8047/query

The logs of the previous queries, their execution plans and delays, as well as the list of queries currently in execution (with the option to cancel them) are available at:

        http://localhost:8047/profiles

In the Drill Web Console it is possible to change Drill's system options at:

        http://localhost:8047/options

instead of using `ALTER SYSTEM SET`, `ALTER SESSION SET`, or `SET` commands in the command-line Shell client.

The Drill's performance metrics are available at:

        http://localhost:8047/metrics

(Note: There are other TCP ports used by Drill, see [http://drill.apache.org/docs/ports-used-by-drill/](http://drill.apache.org/docs/ports-used-by-drill/) and [https://drill.apache.org/docs/architecture-introduction/#drill-clients](https://drill.apache.org/docs/architecture-introduction/#drill-clients).)

# Apache Drill's HTTP RESTful API

Apache Drill also offers a RESTful API at the same tcp port, 8047 (default).

For example, you can submit SQL queries to this interface, and the script [Restful_API_query_LAMetro_NextBus_vehicle_positions.sh](Restful_API_query_LAMetro_NextBus_vehicle_positions.sh) in this repository gives an example, with an external JSON file containing the SQL instruction to submit at [Restful_API_query_LAMetro_NextBus_vehicle_positions.json](Restful_API_query_LAMetro_NextBus_vehicle_positions.json). (There are more details of this functionality at [https://drill.apache.org/docs/rest-api/#query](https://drill.apache.org/docs/rest-api/#query).)

There is a very fast and easy-to-use Drill log parser at `http://<drill-listening-address>:8047/profiles.json`, which can give in JSON format the profiles of the running and completed queries, time of execution, etc., as well as the possibility to cancel running queries. For example:

      curl http://localhost:8047/profiles.json

[https://drill.apache.org/docs/rest-api/#profiles](https://drill.apache.org/docs/rest-api/#profiles) has the formal documentation of this functionality.

To check the run-time of Drill, the `/options.json` entry is also very useful (detailed at [https://drill.apache.org/docs/rest-api/#options](https://drill.apache.org/docs/rest-api/#options)):

      curl http://localhost:8047/options.json

          ...
          {
            "name" : "store.json.read_numbers_as_double",
            "value" : false,
            "type" : "SYSTEM",
            "kind" : "BOOLEAN"
          }, {
            "name" : "exec.java_compiler_debug",
            "value" : true,
            "type" : "SYSTEM",
            "kind" : "BOOLEAN"
          }, {
            "name" : "drill.exec.functions.cast_empty_string_to_null",
            "value" : false,
            "type" : "SYSTEM",
            "kind" : "BOOLEAN"
          }
          ...

For supervising whether Apache Drill is up under network monitoring systems, Drill offers the `status.json` RESTful entry, where the network monitoring system needs to check its answer:

      curl http://localhost:8047/status.json

          {
            "status" : "Running!"
          }

Drill also offers detailed performance metrics to these network monitoring systems and also to trending systems, through its `/status/metrics` RESTful entry. For example, just a short section of its metrics report (consult [https://drill.apache.org/docs/rest-api/#metrics](https://drill.apache.org/docs/rest-api/#metrics) for more details):

      # the request by a network monitoring and/or trending system
      # for performance metrics might be similar to:
     
      curl http://localhost:8047/status/metrics

          ...
          "histograms": {
              "drill.allocator.normal.hist": {
                  "count": 722,
                  "max": 65536,
                  "mean": 4367.608033240997,
                  "min": 1,
                  "p50": 512.0,
                  "p75": 4096.0,
                  "p95": 16384.0,
                  "p98": 32768.0,
                  "p99": 57999.359999999404,
                  "p999": 65536.0,
                  "stddev": 9249.677313565859
              }
              ...
          },
          ...
          "timers": {
              "org.apache.drill.exec.store.schedule.BlockMapBuilder.blockMapBuilderTimer": {
                  "count": 1,
                  "duration_units": "seconds",
                  "m15_rate": 2.0707471789958063e-08,
                  "m1_rate": 0.06844942451529727,
                  "m5_rate": 0.008017692801515435,
                  "max": 0.015364698000000001,
                  "mean": 0.015364698000000001,
                  "mean_rate": 0.0010286016395554193,
                  "min": 0.015364698000000001,
                  "p50": 0.015364698000000001,
                  "p75": 0.015364698000000001,
                  "p95": 0.015364698000000001,
                  "p98": 0.015364698000000001,
                  "p99": 0.015364698000000001,
                  "p999": 0.015364698000000001,
                  "rate_units": "calls/second",
                  "stddev": 0.0
              }

[https://drill.apache.org/docs/monitoring-metrics/](https://drill.apache.org/docs/monitoring-metrics/) has the list of pre-defined metrics. Besides, Apache Drill can write its performance metrics periodically to the log file if the system option `drill.metrics.log.enabled` is set to `true`, and then the option `drill.metrics.log.interval` is set to the period in seconds (default: 60 seconds) after which Drill must write its performance metrics to the log file (improvement ticket `[DRILL-4654]`, implemented). ([https://github.com/apache/drill/blob/master/common/src/main/java/org/apache/drill/exec/metrics/DrillMetrics.java](https://github.com/apache/drill/blob/master/common/src/main/java/org/apache/drill/exec/metrics/DrillMetrics.java) has details of the Drill internal performance metrics.)

# Apache Drill's Storage plugins

Drill is a SQL-like interface for consulting data in different backends. These backends are accessed by different **storage plugins**. These storage plugins can be enabled, disabled, or updated in the Drill Web Console at:

        http://localhost:8047/storage

with plugins for storage in `cp`, `dfs`, `hbase`, `hive`, `kudu`, `mongo`, and `s3`. You can list the configuration, create, enable, or disable different storage plugins through the RESTful API at its `/storage/...` API entry. (See [https://drill.apache.org/docs/rest-api/#storage](https://drill.apache.org/docs/rest-api/#storage) for more details.)

In the links below there are more information about the storage plugins:

        https://drill.apache.org/docs/connect-a-data-source-introduction/
        https://drill.apache.org/docs/storage-plugin-registration/

and more details on configuring Drill's storage plugins at:

        https://drill.apache.org/docs/plugin-configuration-basics/

e.g., for the section **Bootstrapping a Storage Plugin** on how to bootstrap a storage plugin since the very moment Apache Drill starts.

