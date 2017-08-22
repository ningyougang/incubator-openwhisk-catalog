#!/bin/bash
#
# utility functions used when installing standard whisk assets during deployment
#
# Note use of --apihost, this is needed in case of a b/g swap since the router may not be
# updated yet and there may be a breaking change in the API. All tests should go through edge.

SCRIPTDIR="$(cd $(dirname "$0")/ && pwd)"
OPENWHISK_HOME=${OPENWHISK_HOME:-$SCRIPTDIR/../../openwhisk}

: ${WHISK_SSL_SWITCH:?"WHISK_SSL_SWITCH must be set and non-empty"}
SSL_SWITCH=$WHISK_SSL_SWITCH

: ${WHISK_SYSTEM_AUTH:?"WHISK_SYSTEM_AUTH must be set and non-empty"}
AUTH_KEY=$WHISK_SYSTEM_AUTH

: ${WHISK_CERT_FILE:?"WHISK_CERT_FILE must be set and non-empty"}
: ${WHISK_KEY_FILE:?"WHISK_KEY_FILE must be set and non-empty"}
CERT_FILE=$WHISK_CERT_FILE
KEY_FILE=$WHISK_KEY_FILE

AUTH="--auth $AUTH_KEY"
if [ "$SSL_SWITCH" != "off" ]; then
    AUTH="--cert $CERT_FILE --key $KEY_FILE"
fi

: ${WHISK_API_HOST:?"WHISK_API_HOST must be set and non-empty"}
EDGE_HOST=$WHISK_API_HOST

function createPackage() {
    PACKAGE_NAME=$1
    REST=("${@:2}")
    CMD_ARRAY=("$WHISK_CLI_PATH" -i --apihost "$EDGE_HOST" package update $AUTH --shared yes "$PACKAGE_NAME" "${REST[@]}")
    export WSK_CONFIG_FILE= # override local property file to avoid namespace clashes
    "${CMD_ARRAY[@]}" &
    PID=$!
    PIDS+=($PID)
    echo "Creating package $PACKAGE_NAME with pid $PID"
}

function install() {
    RELATIVE_PATH=$1
    ACTION_NAME=$2
    REST=("${@:3}")
    CMD_ARRAY=("$WHISK_CLI_PATH" -i --apihost "$EDGE_HOST" action update $AUTH "$ACTION_NAME" "$RELATIVE_PATH" "${REST[@]}")
    export WSK_CONFIG_FILE= # override local property file to avoid namespace clashes
    "${CMD_ARRAY[@]}" &
    PID=$!
    PIDS+=($PID)
    echo "Installing $ACTION_NAME with pid $PID"
}

function runPackageInstallScript() {
    "$1/$2" &
    PID=$!
    PIDS+=($PID)
    echo "Installing package $2 with pid $PID"
}

function removePackage() {
    PACKAGE_NAME=$1
    REST=("${@:2}")
    CMD_ARRAY=("$WHISK_CLI_PATH" -i --apihost "$WHISK_API_HOST" package delete $AUTH "$WHISK_SYSTEM_AUTH" "$PACKAGE_NAME")
    export WSK_CONFIG_FILE= # override local property file to avoid namespace clashes
    "${CMD_ARRAY[@]}" &
    PID=$!
    PIDS+=($PID)
    echo "Deleting package $PACKAGE_NAME"
}

function removeAction() {
    ACTION_NAME=$1
    REST=("${@:2}")
    CMD_ARRAY=("$WHISK_CLI_PATH" -i --apihost "$WHISK_API_HOST" action delete $AUTH "$WHISK_SYSTEM_AUTH" "$ACTION_NAME")
    export WSK_CONFIG_FILE= # override local property file to avoid namespace clashes
    "${CMD_ARRAY[@]}" &
    PID=$!
    PIDS+=($PID)
    echo "Deleting action $ACTION_NAME"
}

# PIDS is the list of ongoing processes and ERRORS the total number of processes that failed
PIDS=()
ERRORS=0

# Waits for all processes in PIDS and clears it - updating ERRORS for each non-zero status code
function waitForAll() {
    for pid in ${PIDS[@]}; do
        wait $pid
        STATUS=$?
        echo "$pid finished with status $STATUS"
        if [ $STATUS -ne 0 ]
        then
            let ERRORS=ERRORS+1
        fi
    done
    PIDS=()
}
