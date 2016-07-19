# WIP

This is the very first draft, which is a *work in progress*. The implementation is *incomplete* and subject to change. The documentation can be inaccurate.

# Intro

Apache Drill is a very flexible and powerful SQL-like tool that allows to query many different data-sources, not only RDBMSs but also JSON files, `MongoDB`, `HBase`, `Hive`, etc.

# How to Install

Download the Apache Drill tar-ball from [https://drill.apache.org/download/](https://drill.apache.org/download/) and then untar it in some location, like:

        tar xf apache-drill-1.7.0.tar.gz

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

The list of Drill Shell commands (not the SQL-alike commands) is available at [https://drill.apache.org/docs/configuring-the-drill-shell/](https://drill.apache.org/docs/configuring-the-drill-shell/). For example, if after some window of inactivity you lose connectivity to Drillbit, receiving a message like:

        Error: SYSTEM ERROR: IllegalArgumentException: Attempted to send a message when connection is no longer valid.

        Query submission to Drillbit failed.

you can reconnect your shell session to Drillbit using:

        0: jdbc:drill:zk=local> !reconnect jdbc:drill:drillbit=localhost

# Some SQL-alike commands:

        0: jdbc:drill:zk=local> SELECT * FROM dfs.`<local-filesystem-path-to>/a_json_file.json` LIMIT 5 ;

( ... TODO: more SQL-like commands to put here ... )

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

Instead of using the command-line oriented Drill Shell, you may use its HTTP interface, which is very easy and intuitive. It listens by default at port tcp/8047. For example, to submit SQL-like queries, go to (supposing it is running locally):

        http://localhost:8047/query

The logs of the previous queries, their execution plans and delays, is available at:

        http://localhost:8047/profiles

In the Drill Web console it is possible to change Drill's system options at:

        http://localhost:8047/options

instead of using `ALTER SYSTEM` or `SET` commands in the command-line Shell client.

The Drill's performance metrics are available at:

        http://localhost:8047/metrics

(Note: There are other TCP ports used by Drill, see [http://drill.apache.org/docs/ports-used-by-drill/](http://drill.apache.org/docs/ports-used-by-drill/).)

# Apache Drill's Storage plugins

Drill is a SQL-like interface for consulting data in different backends. These backends are accessed by different **storage plugins**. These storage plugins may be enabled, disabled, or updated in the Web interface at:

        http://localhost:8047/storage

with plugins for storage in `cp`, `dfs`, `hbase`, `hive`, `kudu`, `mongo`, and `s3`. In the links below there are more information about the storage plugins:

        https://drill.apache.org/docs/connect-a-data-source-introduction/
        https://drill.apache.org/docs/storage-plugin-registration/

and more details on configuring Drill's storage plugins at:

        https://drill.apache.org/docs/plugin-configuration-basics/

e.g., for the section **Bootstrapping a Storage Plugin** on how to bootstrap a storage plugin since the very moment Apache Drill starts.

