#!/bin/bash

if [[ ! "$SCRIPT_DIR" ]]; then
	pushd . > /dev/null
	SCRIPT_DIR="${BASH_SOURCE[0]}";
	if ([ -h "${SCRIPT_DIR}" ]) then
	  while([ -h "${SCRIPT_DIR}" ]) do cd `dirname "$SCRIPT_DIR"`; SCRIPT_DIR=`readlink "${SCRIPT_DIR}"`; done
	fi
	cd `dirname ${SCRIPT_DIR}` > /dev/null
	export SCRIPT_DIR=`pwd`;
	popd  > /dev/null
fi

source $SCRIPT_DIR/dev-docker-env.sh

OVERRIDE_FILES=""

for ov_file in ${DOCKER_DEV_OVERRIDE_FILES[@]}; do

	#echo $ov_file
	if [ -e "$ov_file" ]; then
		OVERRIDE_FILES="$OVERRIDE_FILES -f $ov_file"
	fi
done

if [[ "$SHARED_CONTAINER_NAME" ]]; then

	if [ ! "$(docker ps -q -f name=$SHARED_CONTAINER_NAME)" ]; then
	    if [ "$(docker ps -aq -f status=exited -f name=$SHARED_CONTAINER_NAME)" ]; then
	        # cleanup
	        docker rm $SHARED_CONTAINER_NAME 1>/dev/null 
	    fi

	    docker-compose  -f $SCRIPT_DIR/dev-docker-compose.yml $OVERRIDE_FILES run $DEV_DOCKER_START_ARGS -d --rm --name "$SHARED_CONTAINER_NAME"  dev-env sh -c "while true; do sleep 10000; done" 1>/dev/null 

		#echo "wait for $SHARED_CONTAINER_NAME to start..."
		until [ "`docker inspect -f {{.State.Running}} \"$SHARED_CONTAINER_NAME\" `" != "" ]; do sleep 0.1; done;

	fi

	function docker_exec_cleanup {
		#echo "kill signal $PIDFILE"
    	docker exec "$SHARED_CONTAINER_NAME" bash -c "if [ -f $PIDFILE ]; then kill -TERM -\$(cat $PIDFILE) &>/dev/null; fi"
	}


	DEV_DOCKER_PROCESS_ARGS="-i $DEV_DOCKER_PROCESS_ARGS"
	if tty -s
	then
		DEV_DOCKER_PROCESS_ARGS="-t $DEV_DOCKER_PROCESS_ARGS"
	fi

	PIDFILE=/tmp/docker-exec-$$
	trap 'kill $DOC_PID &>/dev/null; docker_exec_cleanup' EXIT TERM INT
	docker exec $DEV_DOCKER_PROCESS_ARGS "$SHARED_CONTAINER_NAME" $DOCKER_DEV_HOME/scripts/exec_in_dev_docker.sh "$PIDFILE" "$PWD" "$@" <&0 &
	DOC_PID=$!
    
else	
	container_name="dev_docker_$(uuidgen)"

	if tty -s
	then
		docker-compose -f $SCRIPT_DIR/dev-docker-compose.yml $OVERRIDE_FILES run $DEV_DOCKER_START_ARGS --rm $DEV_DOCKER_PROCESS_ARGS --name "$container_name" -w "$PWD" dev-env "$@" <&0 &
		DOC_PID=$!
	else
		script -q /dev/null docker-compose -f $SCRIPT_DIR/dev-docker-compose.yml $OVERRIDE_FILES run $DEV_DOCKER_START_ARGS  --rm $DEV_DOCKER_PROCESS_ARGS --name "$container_name" -w "$PWD" dev-env "$@" <&0  &
		DOC_PID=$!
	fi

	trap 'docker stop "$container_name" &>/dev/null' EXIT TERM INT
	
fi

wait $DOC_PID
trap - EXIT TERM INT
wait $DOC_PID
EXIT_STATUS=$?
#echo "Exiting .....  $EXIT_STATUS"
exit $EXIT_STATUS
