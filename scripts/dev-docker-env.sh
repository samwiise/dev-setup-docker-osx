export PATH=$PATH:/usr/local/bin

export DOCKER_DEV_HOME=$HOME/.docker-dev-env

DOCKER_DEV_OVERRIDE_FILES= ("$DOCKER_DEV_HOME/scripts/pycharm-docker-compose.yml" \
							"$DOCKER_DEV_HOME/scripts/dev-docker-compose.override.yml")
							

