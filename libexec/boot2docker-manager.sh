#!/bin/bash
# boot2docker manager

fullSrcDir() {
  echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
}
source "$( fullSrcDir )/utils.sh"

Boot2DockerManager() {
  require Class
  _boot2DockerConstructor=$FUNCNAME

  Boot2DockerManager:new() {
    local this="$1"
    local constructor=$_boot2DockerConstructor
    Class:addInstanceMethod $constructor $this 'validate' 'Boot2DockerManager.validate'
    Class:addInstanceMethod $constructor $this 'dockerHostIP' 'Boot2DockerManager.dockerHostIP'
    Class:addInstanceMethod $constructor $this 'dockerHostPort' 'Boot2DockerManager.dockerHostPort'
    Class:addInstanceMethod $constructor $this 'dockerHost' 'Boot2DockerManager.dockerHost'
    Class:addInstanceMethod $constructor $this 'dockerCert' 'Boot2DockerManager.dockerCert'
    Class:addInstanceMethod $constructor $this 'dockerTls' 'Boot2DockerManager.dockerTls'
  }

  Boot2DockerManager.validate() {
    local instance="$1"
    if [[ -z $( command -v boot2docker ) ]]; then
      Class:exception "Please install boot2docker"
    else
      boot2docker stop
      boot2docker up
    fi
  }

  Boot2DockerManager.dockerHostIP() {
    # local instance="$1"
    [[ "$( boot2docker ip )" =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]] &>/dev/null \
      && echo ${BASH_REMATCH[@]}
  }

  Boot2DockerManager.dockerHostPort() {
    # local instance="$1"
    boot2docker info | sed -e 's#{##g;s#}##g' | while read -r -d ',' chunk; do
      if [[ "$chunk" =~ DockerPort ]]; then
        echo "$chunk"
      fi
    done | cut -d ':' -f2
  }

  Boot2DockerManager.dockerHost() {
    local instance=$1
    # echo "192.168.59.103:2376"
    echo "tcp://$( eval "echo \$${instance}_dockerHostIP" ):$( eval "echo \$${instance}_dockerHostPort")"
  }

  Boot2DockerManager.dockerCert() {
    local instance=$1
    echo "$HOME/.boot2docker/certs/boot2docker-vm"
  }

  Boot2DockerManager.dockerTls() {
    local instance=$1
    echo "1"
  }

  Boot2DockerManager:required() {
    export -f Boot2DockerManager:new
  }
  export -f Boot2DockerManager:required
}
