#!/bin/bash

start() {
	id="$1"
	shift
	docker run --rm -d -v $PWD/sentinel-"${id}".conf:/data/sentinel.conf --name "redis-${id}" -it redis:6.0.6 "${@}"
}

connect() {
	id="$1"
	shift
	cmd="$@"
	if [ "${#@}" = "0" ]; then
	  docker exec -it "redis-${id}" /bin/bash
        else
	  docker exec -it "redis-${id}" /bin/bash -c "${cmd}"
	fi
}

ip() {
	id="$1"
	docker inspect "redis-${id}" -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
}

kill() {
	id="$1"
	docker rm -f "redis-${id}"
}
