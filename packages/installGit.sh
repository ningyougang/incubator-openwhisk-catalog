#!/bin/bash
#
# use the command line interface to install Git package.
#
SCRIPTDIR="$(cd $(dirname "$0")/ && pwd)"
PACKAGE_HOME=$SCRIPTDIR
source "$PACKAGE_HOME/util.sh"

echo Installing Git package.

createPackage github \
    -p endpoint "openwhisk.ng.bluemix.net" \
    -a description "Package which contains actions and feeds to interact with Github"

waitForAll

install "$PACKAGE_HOME/github/webhook.js" \
    github/webhook \
    -a feed true \
    -a description 'Creates a webhook on GitHub to be notified on selected changes' \
    -a parameters '[ {"name":"username", "required":true, "bindTime":true, "description": "Your GitHub username"}, {"name":"repository", "required":true, "bindTime":true, "description": "The name of a GitHub repository"}, {"name":"accessToken", "required":true, "bindTime":true, "description": "A webhook or personal token", "doclink": "https://github.com/settings/tokens/new"},{"name":"events", "required":true, "description": "A comma-separated list", "doclink": "https://developer.github.com/webhooks/#events"} ]' \
    -a sampleInput '{"username":"myUserName", "repository":"myRepository or myOrganization/myRepository", "accessToken":"123ABCXYZ", "events": "push,delete,pull-request"}'

waitForAll

echo Git package ERRORS = $ERRORS
exit $ERRORS
