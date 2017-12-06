#!/bin/bash

cd "$MY_DOCKER_PWD"

for add_paths in ${!ADD_TO_PATH_*}
do
	add_paths="${!add_paths}"
	ADD_PATHS="$add_paths:$ADD_PATHS"	
	#echo $ADD_PATHS
done

export PATH="$ADD_PATHS:$PATH"

exec "$@" 
