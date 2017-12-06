#!/bin/bash

PIDFILE=$1
shift
cd $1 
shift

export DO_NOT_MOUNT="TRUE"

echo $$ > $PIDFILE

trap 'kill $PID &>/dev/null' EXIT TERM INT
$DOCKER_DEV_HOME/scripts/entrypoint-dev-docker.sh "$@" <&0 &
PID=$!
wait $PID
trap - EXIT TERM INT
wait $PID
EXIT_STATUS=$?
rm $PIDFILE
exit $EXIT_STATUS