#!/bin/bash

start() {
	id="$1"
	shift
	docker run --rm -d -v $PWD/sentinel-"${id}".conf:/data/sentinel.conf --name "redis-${id}" -it redis:6.0.6 "${@}"
}

connect() {
	id="$1"
	docker exec -it "redis-${id}" /bin/bash
}

ip() {
	id="$1"
	docker inspect "redis-${id}" -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
}

kill() {
	id="$1"
	docker rm -f "redis-${id}"
}
