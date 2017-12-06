
PyCharm native OSX application integerated with python virtual environment in linux using docker.

### Setup Docker Based Development Environment for Mac OSX

Setup Development Shell and Python Environment:

 - Now DOCKER_DEV_HOME is set to be inside user home folder $HOME/.docker-dev-env and can be changed inside scripts/dev-docker-env.sh

 - Create directory inside user home folder, $HOME/.docker-dev-env that is DOCKER_DEV_HOME
 - Copy scripts folder inside $DOCKER_DEV_HOME.
 - Open terminal cd into $DOCKER_DEV_HOME/scripts.

 - Execute script ./create-python-env.sh <IMAGE> [<environment name>]

 	e.g. ./create-python-env.sh ubuntu:12.04                 

 	Environment name is optional if not specified image name is used, e.g. "ubuntu_12.04".


 - Wait for the script to finish and output message like the following

 		e.g.
 		"Creating docker compose yaml /Users/asim_ali/.docker-dev-env/env-ubuntu_12.04/python-dev-docker-compose.override.yml"
 
 - Using the docker compose yaml file mentioned in the message, environment can be customized like more volumes can be mounted(source folder etc), add links to other docker containers(mongo,redis,es etc)

 - Add the customized docker compose yaml path to DOCKER_DEV_OVERRIDE_FILES list variable inside $DOCKER_DEV_HOME/scripts/dev-docker-env.sh

 - Add this $DOCKER_DEV_HOME/scripts to your PATH inside ~/.bash_profile to be accessible from anywhere.

 - Now type "chroot-docker bash" to open a shell inside the created development environment, whatever changes are made they are persisted inside the folder $DOCKER_DEV_HOME/env-<environment name>

 	try installing different packages with pip or apt-get, they are all persisted even when you exit the shell, type "exit".

 - Check "python-docker --version" , this python interpreter is run inside the created development environment.

    Note: Better execute chroot-docker or python-docker from a folder which is mounted into docker via customized docker compose yaml mentioned earlier.

 

## To integrate with PyCharm

Install PyCharm version PyCharmCE2017.2 or change the respective folder name inside the file $DOCKER_DEV_HOME/scripts/pycharm-docker-compose.yml
 
 - ADD this "$DOCKER_DEV_HOME/scripts/pycharm-docker-compose.yml" to DOCKER_DEV_OVERRIDE_FILES inside $DOCKER_DEV_HOME/scripts/dev-docker-env.sh

 - Open PyCharm Preferences and Add new Python Interpreter at this path "$DOCKER_DEV_HOME/env-<environment name>/python-dev-env/bin/python-docker"


Note: Right now there is a limitation with PyCharm integration, "python-docker" and "chroot-docker" interpreter does not support reading from redirected stdin that is "python-docker test.py < test-file.txt" or "cat test-file.txt | python-docker test.py" will not work. Because of this some PEP 8 PyCharm inspections doesn't work and should be disabled from Preferences>Editor>Inspections.


