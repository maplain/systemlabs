#!/bin/bash

lab2_1() {
	source docker-utils.sh
	connect 0
	tail -f appendonly.aof
}
