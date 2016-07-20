

-- This is an example SQL query to show the flexibility of Apache Drill

SELECT vehicles._links.self.href as vehicles, vehicles.routeId,
       vehicles.directionId, vehicles.heading, vehicles.kph, vehicles.lat,
       vehicles.lon, vehicles.secsSinceReport
     FROM dfs.`/tmp/lametro_vehicles.json`  vehicles
     WHERE vehicles.secsSinceReport > 60
     ORDER BY vehicles.secsSinceReport DESC
     LIMIT 10;

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

