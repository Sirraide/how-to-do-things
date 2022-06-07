#!/usr/bin/env bash
trap killpg SIGINT

killpg() {
	local pgid
	pgid="$(ps -o pgid= -q $$ | tr -d ' ')"
	kill -9 -$pgid
}

while true; do true; done
