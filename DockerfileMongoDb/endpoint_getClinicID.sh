#!/bin/bash
#
# Append Endpoint to the Hub's public (authorized) key list


# Halt on errors or unset variables
#
set -e -o nounset


# Expected input
#
# $0 this script
# $1 Gateway ID number


# Check parameters
#
if [ $# -ne 1 ]
then
	echo ""
	echo "Unexpected number of parameters."
	echo ""
	echo "Usage: endpoint_getClinicID.sh [gatewayID]"
	echo ""
	exit
fi


# Obtain clinic number
#
mongo query_composer_development --eval \
  'printjson( db.endpoints.findOne({ base_url : "http://localhost:'$(expr 40000 + $1)'" }))' \
  | grep ObjectId | grep -o "(.*)" | grep -io "\w\+"
