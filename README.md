# WIP

This is the very first draft, which is a *work in progress*. The implementation is *incomplete* and subject to change. The documentation can be inaccurate.

# Intro

Apache Drill is a very flexible and powerful SQL-like tool that allows to query many different data-sources, not only RDBMSs but also JSON and CSV files, `MongoDB`, `HBase`, `Hive`, etc. (Consult here [https://drill.apache.org/docs/query-data-introduction/](https://drill.apache.org/docs/query-data-introduction/) for the current list of possible data-sources.) Hence, it is not only useful for ad-hoc queries, but also for ETL jobs.

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

You may want to check the `./log/sqlline.log` log file if any issue occurs. This log file is located by default under the base directory where the tar-ball was extracted.

The list of commands directly for the Drill Shell (ie., not the SQL-alike commands) is available at [https://drill.apache.org/docs/configuring-the-drill-shell/](https://drill.apache.org/docs/configuring-the-drill-shell/). For example, if after some window of inactivity the Drill Shell loses connectivity to Drillbit, showing a message like:

        Error: SYSTEM ERROR: IllegalArgumentException: Attempted to send a message when connection is no longer valid.

        Query submission to Drillbit failed.

you can reconnect your shell session to Drillbit using:

        0: jdbc:drill:zk=local> !reconnect jdbc:drill:drillbit=localhost

# Some SQL-alike commands:

For example, a very simple query on a JSON file could be:

        0: jdbc:drill:zk=local> SELECT * FROM dfs.`<local-filesystem-path-to>/a_json_file.json` LIMIT 5 ;

At [https://drill.apache.org/docs/json-data-model/](https://drill.apache.org/docs/json-data-model/) there are more examples and guides on how to query JSON data. For example, and citing from this document (*[quotes]* in brackets are summaries for here, you should consult this document):

- *By default, Drill does not support JSON lists [whose elements are] of different types.* [How to alter this default and other workarounds are shown. In short, Drill is, _by default_, stronger typed than JSON, which of course isn't typed at all.]

- *The Union type allows storing different types in the same field.*

- *Drill returns null when a document does not have the specified map or level.* [For example, the case where some JSON paths have some maps or levels but other JSON paths in the same document don't have them.]

- How to use the FLATTEN and KVGEN functions.

- Other very instructive examples.

Here it is shown an example querying JSON data, using also the [Drill-GIS plugin](https://github.com/k255/drill-gis), in the script `query_LosAngelesMetro_NextBus_vehicle_positions.sh`. It has two queries which give results like (the data from http://restbus.info/ is real-time, so there results probably vary in another run), plus an ETL job on the data which creates a transformed and filtered JSON file from the original:

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

# Apache Drill's HTTP interface

Instead of using the command-line oriented Drill Shell, you may use its HTTP interface, which is very easy and intuitive. The Drill Web Console listens by default at port tcp/8047. For example, to submit SQL-like queries, go to (supposing it is running locally):

        http://localhost:8047/query

The logs of the previous queries, their execution plans and delays, as well as the list of queries currently in execution (with the option to cancel them) are available at:

        http://localhost:8047/profiles

In the Drill Web Console it is possible to change Drill's system options at:

        http://localhost:8047/options

instead of using `ALTER SYSTEM SET`, `ALTER SESSION SET`, or `SET` commands in the command-line Shell client.

The Drill's performance metrics are available at:

        http://localhost:8047/metrics

(Note: There are other TCP ports used by Drill, see [http://drill.apache.org/docs/ports-used-by-drill/](http://drill.apache.org/docs/ports-used-by-drill/) and [https://drill.apache.org/docs/architecture-introduction/#drill-clients](https://drill.apache.org/docs/architecture-introduction/#drill-clients).)

# Apache Drill's Storage plugins

Drill is a SQL-like interface for consulting data in different backends. These backends are accessed by different **storage plugins**. These storage plugins can be enabled, disabled, or updated in the Drill Web Console at:

        http://localhost:8047/storage

with plugins for storage in `cp`, `dfs`, `hbase`, `hive`, `kudu`, `mongo`, and `s3`. In the links below there are more information about the storage plugins:

        https://drill.apache.org/docs/connect-a-data-source-introduction/
        https://drill.apache.org/docs/storage-plugin-registration/

and more details on configuring Drill's storage plugins at:

        https://drill.apache.org/docs/plugin-configuration-basics/

e.g., for the section **Bootstrapping a Storage Plugin** on how to bootstrap a storage plugin since the very moment Apache Drill starts.

