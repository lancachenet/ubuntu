#!/bin/bash
which goss

if [ $? -ne 0 ]; then
	echo "Please install goss from https://goss.rocks/install"
	echo "For a quick auto install run the following"
	echo "curl -fsSL https://goss.rocks/install | sh"
	exit $?
fi

docker build --tag steamcache/ubuntu:testing .
dgoss run $@ steamcache/ubuntu:testing
docker rmi steamcache/ubuntu:testing
