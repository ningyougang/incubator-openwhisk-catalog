#!/bin/bash
#
# use the command line interface to install standard actions deployed
# automatically
#
# To run this command
# ./installCatalog.sh  <SSL_SWITCH> <AUTH> <CERT_FILE> <KEY_FILE> <APIHOST> <WSK_CLI>
: ${OPENWHISK_HOME:?"OPENWHISK_HOME must be set and non-empty"}

SCRIPTDIR="$(cd $(dirname "$0")/ && pwd)"
OPENWHISK_HOME=${OPENWHISK_HOME:-$SCRIPTDIR/../../openwhisk}

source "$SCRIPTDIR/validateParameter.sh" $1 $2 $3 $4 $5 $6
: ${WHISK_SSL_SWITCH:?"WHISK_SSL_SWITCH is not configured. Please input the correctly parameter: SSL_SWITCH"}
: ${WHISK_SYSTEM_AUTH:?"WHISK_SYSTEM_AUTH is not configured. Please input the correctly parameter: CATALOG_AUTH_KEY"}
: ${WHISK_CERT_FILE:?"WHISK_CERT_FILE is not configured. Please input the correctly parameter: CATALOG_CERT_FILE"}
: ${WHISK_KEY_FILE:?"WHISK_KEY_FILE is not configured. Please input the correctly parameter: CATALOG_KEY_FILE"}
: ${WHISK_API_HOST:?"WHISK_API_HOST is not configured. Please input the correctly parameter: API_HOST"}
: ${WHISK_CLI_PATH:?"WHISK_CLI_PATH is not configured. Please input the correctly parameter: cli_path"}

source "$SCRIPTDIR/util.sh"

echo Installing OpenWhisk packages

runPackageInstallScript "$SCRIPTDIR" installCombinators.sh
runPackageInstallScript "$SCRIPTDIR" installGit.sh
runPackageInstallScript "$SCRIPTDIR" installSlack.sh
runPackageInstallScript "$SCRIPTDIR" installSystem.sh
runPackageInstallScript "$SCRIPTDIR" installWatson.sh
runPackageInstallScript "$SCRIPTDIR" installWeather.sh
runPackageInstallScript "$SCRIPTDIR" installWebSocket.sh

waitForAll

echo open catalog ERRORS = $ERRORS
exit $ERRORS
