#!/bin/bash
#
# use the command to validate the input parameters
#

# The first argument is the client certificate switch
SSL_SWITCH=${1:-"off"}
: ${SSL_SWITCH:?"SSL_SWITCH must be set and non-empty"}
export WHISK_SSL_SWITCH=$SSL_SWITCH

# The second argument is the catalog authentication key, which can be passed via either
# a file or the key itself.
CATALOG_AUTH_KEY=${2:-"$OPENWHISK_HOME/ansible/files/auth.whisk.system"}

# If the auth key file exists, read the key in the file. Otherwise, take the
# second argument as the key itself.
if [ -f "$CATALOG_AUTH_KEY" ]; then
    CATALOG_AUTH_KEY=`cat $CATALOG_AUTH_KEY`
fi

# Make sure that the catalog_auth_key is not empty.
: ${CATALOG_AUTH_KEY:?"CATALOG_AUTH_KEY must be set and non-empty"}
export WHISK_SYSTEM_AUTH=$CATALOG_AUTH_KEY

CATALOG_CERT_FILE=${3:-"$OPENWHISK_HOME/ansible/roles/nginx/files/openwhisk-client-cert-whisk-system.pem"}
CATALOG_KEY_FILE=${4:-"$OPENWHISK_HOME/ansible/roles/nginx/files/openwhisk-client-key-whisk-system.pem"}
: ${CATALOG_CERT_FILE:?"CATALOG_CERT_FILE must be set and non-empty"}
: ${CATALOG_KEY_FILE:?"CATALOG_KEY_FILE must be set and non-empty"}
export WHISK_CERT_FILE=$CATALOG_CERT_FILE
export WHISK_KEY_FILE=$CATALOG_KEY_FILE

# The api host is passed as the fifth argument. If it is not provided, take the edge
# host from the whisk properties file.
API_HOST=$5
if [ -z "$API_HOST" ]; then
    WHISKPROPS_FILE="$OPENWHISK_HOME/whisk.properties"
    if [ ! -f "$WHISKPROPS_FILE" ]; then
        echo "API_HOST must be set and non-empty."
        exit 1
    fi
    API_HOST=`fgrep edge.host= "$WHISKPROPS_FILE" | cut -d'=' -f2`
fi

# Make sure that the api_host is not empty.
: ${API_HOST:?"API_HOST must be set and non-empty"}
export WHISK_API_HOST=$API_HOST

# The CLI path is passed as the sixth argument. If it is not provided, use
# "$OPENWHISK_HOME/bin/wsk" as the default value.
cli_path=${6:-"$OPENWHISK_HOME/bin/wsk"}
export WHISK_CLI_PATH=$cli_path
