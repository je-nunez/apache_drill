#!/bin/sh

# RestBus.info returns a JSON file with several data from the NextBus Transit
# system. Consult their web-site http://restbus.info/ for more information on
# the available queries.

# Obtain current data, in JSON format, about the vehicles (buses) of the Los
# Angeles Metro public transit agency.

LAMetro_CurrVehicles_URL='http://restbus.info/api/agencies/lametro/vehicles'

# Where to save this JSON file

LAMetro_CurrVehicles_file='/tmp/lametro_vehicles.json'

echo "Downloading the RestBus.info JSON file..."

curl "$LAMetro_CurrVehicles_URL"  > "$LAMetro_CurrVehicles_file"

# query the JSON file with Apache Drill (drill-embedded needs to be in your
# PATH environment variable.)

SQL_file=./query_LosAngelesMetro_NextBus_vehicle_positions.sql

drill-embedded --verbose=false --silent=true < "$SQL_file"

