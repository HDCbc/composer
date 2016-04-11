#!/bin/bash
#
# Append Endpoint to the Hub's public (authorized) key list


# Halt on errors or unset variables
#
set -e -o nounset


# Expected input
#
# $0 this script
# $1 Endpoint number


# Check parameters
#
if [ $# -ne 1 ]
then
	echo ""
	echo "Unexpected number of parameters."
	echo ""
	echo "Usage: endpoint_remove.sh [endpointNumber]"
	echo ""
	exit
fi


# Remove entry for an endpoint
#
mongo query_composer_development --eval \
  'db.endpoints.remove({ "base_url" : "http://localhost:'`expr 40000 + ${1}`'" })'
