#!/bin/bash
#
# Bootstraps a new server.
#
# All this script does is send the production bootstrapping script through to
# the server, then executes it.
#
# Usage: bootstrap-server.sh <instance-ip> [<ssh-options>]
# E.g.:  bootstrap-server.sh 184.106.94.194 -i ~/.ssh/sbtfaws.pem
#
# Author: Nigel McNie <nigel@mcnie.name>
#

INSTANCE=$1
shift
SSH_OPTS=$@
REMOTEUSER=ubuntu

echo "Bootstrapping $INSTANCE..."

sudo=''
if [ "$REMOTEUSER" != "root" ]; then
    sudo='sudo'
fi

if [[ ! $INSTANCE =~ .*@.* ]]; then
    INSTANCE="$REMOTEUSER@$INSTANCE"
fi

( scp $SSH_OPTS scripts/production-bootstrap.sh $INSTANCE: && ssh $SSH_OPTS $INSTANCE $sudo sh production-bootstrap.sh $ROLE )
