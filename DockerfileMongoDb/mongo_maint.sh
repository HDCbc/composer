#!/bin/bash
#
# Admin config script for the PDC's HubDB (MongoDB) service


# Halt on errors or unset variables
#
set -e -o nounset


# Wait for mongo to start, important after boot
#
while [ $( pgrep -c mongod ) -eq 0 ]
do
	sleep 60
done
sleep 5


# Set db keys to prevent duplicates
#
mongo query_composer_development --eval \
  'printjson( db.users.ensureIndex({ username : 1 }, { unique: true }))'
mongo query_composer_development --eval \
  'printjson( db.endpoints.ensureIndex({ base_url : 1 }, { unique: true }))'
mongo query_composer_development --eval \
  'printjson( db.users.ensureIndex({ username: 1 }, { unique: true }))'
mongo query_composer_development --eval \
  'printjson( db.queries.ensureIndex({ description: 1 }, { unique: true }))'


# Dump MongoDB, report failure if unsuccessful
#
mkdir -p /data/dump/
mongodump --out /data/dump/


# Import admin and user accounts
#
mongo query_composer_development --eval \
  'db.users.insert({ "first_name" : "PDC", "last_name" : "Admin", "username" : "admin", "email" : "admin@pdcbc.ca", "encrypted_password" : "\$2a\$10\$ZSuPxdODbumiMGOxtVSpRu0Rd0fQ2HhC7tMu2IobKTaAsPMmFlBD.", "agree_license" : true, "approved" : true, "admin" : true })'
mongo query_composer_development --eval \
  'db.users.insert({ "first_name" : "PDC", "last_name" : "User", "username" : "user", "email" : "user@pdcbc.ca", "encrypted_password" : "\$2a\$10\$ZSuPxdODbumiMGOxtVSpRu0Rd0fQ2HhC7tMu2IobKTaAsPMmFlBD.", "agree_license" : true, "approved" : true, "admin" : false })'
