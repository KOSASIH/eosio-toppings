#!/usr/bin/env bash

# change to script's directory
cd "$(dirname "$0")"

# sourcing variable from config file
source ./config.file

# docker did not stop properly
if [ "$(docker ps -q -f status=exited -f name=$NODEOS_CONTAINER_NAME)" ]; then
  docker rm $NODEOS_CONTAINER_NAME
fi

if [ -e "data/initialized" ]
then
    script="./scripts/continue_blockchain.sh"
else
    script="./scripts/init_blockchain.sh"
fi

if [ ! "$(docker ps -q -f name=$NODEOS_CONTAINER_NAME)" ]; then
    # check if data folder is empty else we'll have dirty flag problem in blockchain
    if find "$(pwd)/data" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
        echo "eosio docker is not running, but data folder exists"
        echo "cleaning data now"
        rm -r "$(pwd)"/data/*
    fi

    # --link is to get access to other container
    echo "run docker container from the $NODEOS_IMAGE_NAME image"
    docker run --rm --name $NODEOS_CONTAINER_NAME -d \
    -p 8888:8888 -p 9876:9876 \
    --link $MONGODB_CONTAINER_NAME \
    --mount type=bind,src="$(pwd)"/contracts,dst=/opt/eosio/bin/contracts \
    --mount type=bind,src="$(pwd)"/scripts,dst=/opt/eosio/bin/scripts \
    --mount type=bind,src="$(pwd)"/data,dst=/mnt/dev/data \
    -w "/opt/eosio/bin/" $NODEOS_IMAGE_NAME /bin/bash -c "$script"

    if [ "$1" != "--nolog" ]
    then
        echo "=== follow $NODEOS_CONTAINER_NAME logs ==="
        docker logs $NODEOS_CONTAINER_NAME --follow
    fi
else
    echo "docker already running"
fi
