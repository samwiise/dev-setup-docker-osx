#!/bin/bash

set -e


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

IMAGE=$1


if [[ $# -eq 1 ]]; then
	ENV_NAME="env-${IMAGE//:/_}"
else
	ENV_NAME="env-$2"
fi


#ENV_NAME="chroot-os-$IMAGE"
ENV_FOLDER="$DOCKER_DEV_HOME/$ENV_NAME"

echo "Creating environment in the folder $ENV_FOLDER"

mkdir -p "$ENV_FOLDER/chroot-os"

#Start container to export chroot file system and python environment from

CONTAINER_NAME=`docker run --rm -d -v "$ENV_FOLDER:$ENV_FOLDER" $IMAGE sleep 3600`


docker exec -i "$CONTAINER_NAME" /bin/bash <<EOF

apt-get update

apt-get install -y python-pip curl

curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"

python get-pip.py

pip install virtualenv

echo "Creating python virtualenv into $ENV_FOLDER/python-dev-env"

virtualenv --no-site-packages "$ENV_FOLDER/python-dev-env"

exit
EOF

ln -s "$SCRIPT_DIR/python-docker" "$ENV_FOLDER/python-dev-env/bin/python-docker"

echo "Exporting file system from container $CONTAINER_NAME"

docker export -o "$ENV_FOLDER/chroot-os.tar.gz" "$CONTAINER_NAME"

tar -xf "$ENV_FOLDER/chroot-os.tar.gz" -C "$ENV_FOLDER/chroot-os"  --exclude dev/*  --exclude proc/* --exclude sys/*

rm  "$ENV_FOLDER/chroot-os.tar.gz"

docker rm -vf "$CONTAINER_NAME"



#Create .override.yml docker compose file

echo "Creating docker compose yaml $ENV_FOLDER/python-dev-docker-compose.override.yml"

cat << EOF > "$ENV_FOLDER/python-dev-docker-compose.override.yml"
dev-env:
  image: $IMAGE
  #volumes:
  #  - "/Users/asim_ali/mylab:/Users/asim_ali/mylab"
  #  - "/Users/asim_ali/oslab:/Users/asim_ali/oslab"
  environment:
    - CHROOT_PATH=$ENV_FOLDER/chroot-os
    - ADD_TO_PATH_PYTHON=$ENV_FOLDER/python-dev-env/bin
    #- MOUNT_PATHS_DEV_LAB=/Users/asim_ali/mylab:/Users/asim_ali/oslab
  #external_links:
  #  - mongo_container:mongo_service
EOF
