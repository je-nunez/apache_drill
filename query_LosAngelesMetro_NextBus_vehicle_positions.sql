

-- This is an example SQL query to show the flexibility of Apache Drill

SELECT vehicles._links.self.href as vehicles, vehicles.routeId,
       vehicles.directionId, vehicles.heading, vehicles.kph, vehicles.lat,
       vehicles.lon, vehicles.secsSinceReport
     FROM dfs.`/tmp/lametro_vehicles.json`  vehicles
     WHERE vehicles.secsSinceReport > 60
     ORDER BY vehicles.secsSinceReport DESC
     LIMIT 10;

-- Save the above query (without the LIMIT 10) to a JSON file in the "dfs.tmp"
-- schema. As mentioned in
--       https://drill.apache.org/docs/show-databases-and-show-schemas/:
--
--   "In Drill, a database or schema is a storage plugin configuration that can
--    include a workspace. For example, in dfs.donuts, dfs is the configured
--    file system and donuts the workspace. The workspace points to a directory
--    within the file system."
--
-- so the "dfs.tmp" refers to the system's tmp directory, so the new JSON table
-- will be created by Drill with the new-table-name under the tmp directory.
-- (E.g., querying Apache Drill through its RESTful API on the "dfs" storage
--  plugin:
--
--          curl http://localhost:8047/storage/dfs.json
--
--  can show, summarized for our case:
--
--             "name" : "dfs",
--               "config" : {
--                 "enabled" : true,
--                 "workspaces" : {
--                   "tmp" : {
--                     "location" : "/tmp",
--                     "writable" : true,
--
--  so the "dfs" storage plugin is enabled, and its workspace "dfs.tmp" refers
--  to the directory "/tmp", to which Drill is given write permissions.


ALTER SESSION SET `store.format`='json';
USE dfs.tmp;

DROP TABLE vehicles_with_more_than_60secs_report;

CREATE TABLE vehicles_with_more_than_60secs_report AS
    SELECT vehicles._links.self.href as vehicles, vehicles.routeId,
           vehicles.directionId, vehicles.heading, vehicles.kph, vehicles.lat,
           vehicles.lon, vehicles.secsSinceReport
         FROM dfs.`/tmp/lametro_vehicles.json`  vehicles
         WHERE vehicles.secsSinceReport > 60
         ORDER BY vehicles.secsSinceReport DESC;

-- (For more details: https://drill.apache.org/docs/create-table-as-ctas/ )

-- The query below uses the Drill-GIS plugin, which implements PostGIS functions
-- for Apache Drill, to find those vehicles which are within a given polygon,
-- while GROUPing by those vehicles in the same route and route-direction.
-- (For the Drill-GIS plugin, see https://github.com/k255/drill-gis)

SELECT vehicles.routeId, vehicles.directionId,
       count(*) as numBusesInThisDirection, avg(vehicles.kph) as avgSpeedKpH
     FROM dfs.`/tmp/lametro_vehicles.json`  vehicles
     WHERE ST_Within(
                 ST_Point(vehicles.lon, vehicles.lat),
                 ST_GeomFromText('POLYGON ((-118.5129 34.0241, -118.5129 34.0000, -118.1098 34.0000, -118.1098 34.0241, -118.5129 34.0241))')
           )
     GROUP BY vehicles.routeId, vehicles.directionId
     ORDER BY avgSpeedKpH DESC;

