#!/bin/bash

# Usage: docker_stop_remove_container <container_name>
docker_stop_remove_container() {
    docker stop -t 1 $1
    docker rm $1
}
