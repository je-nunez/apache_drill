#!/bin/sh

# This script does not use Apache Drill in embedded mode (as the other script
# "query_LosAngelesMetro_NextBus_vehicle_positions.sh" does): this script
# does expect that Apache Drill is already running to query it through its
# RESTful API. (Although this script could pre-check whether Drill is running
# or not -ie., listening at the default port tcp/8047- before querying it,
# and if it is not running, start it.)

# our working copy of the original data source

LAMetro_CurrVehicles_file='/tmp/lametro_vehicles.json'

# function to download the original data source

function download_LosAngeles_Metro_CurrVehicles_Pos() {
    LAMetro_CurrVehicles_URL='http://restbus.info/api/agencies/lametro/vehicles'
    echo "Downloading the RestBus.info JSON file..."

    curl "$LAMetro_CurrVehicles_URL"  > "$LAMetro_CurrVehicles_file"
}



## MAIN BODY

if [ ! -f "$LAMetro_CurrVehicles_file" ]
then
     download_LosAngeles_Metro_CurrVehicles_Pos
fi


input_sql_query_json=./Restful_API_query_LAMetro_NextBus_vehicle_positions.json

dest_results_json=/tmp/ETL_results.json

echo "\nQuerying Apache Drill through its Restful API." \
     "ETL JSON results captured to: '$dest_results_json'\n"

# Another script, "query_LosAngelesMetro_NextBus_vehicle_positions.sh", has an
# example of creating the destination results of the ETL inside Apache Drill
# itself through a SQL instruction "CREATE TABLE ... AS (select-statement)".
# Here we just save the standard output returned from the Drill Restful API:
# see the "rows" JSON list in the resulting JSON file, "$dest_results_json".

# mktemp is not 100% equivalent between Linux and Mac/OS, but for this example,
# it will be enough.
save_http_response_headers=`mktemp -t  drill_response.XXXXXXXXXX`

curl -X POST -H "Content-Type: application/json"      \
     -d "@$input_sql_query_json"                      \
     --dump-header "${save_http_response_headers?}"   \
     http://localhost:8047/query.json  > "$dest_results_json"

echo "curl exit-code: $?" \
     "\nApache Drill Restful API response headers ('200 OK' expected):"

cat "${save_http_response_headers?}"
rm -f "${save_http_response_headers?}"

