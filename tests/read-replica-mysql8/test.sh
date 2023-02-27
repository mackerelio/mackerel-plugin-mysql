#!/bin/sh

prog=$(basename "$0")
if ! [ -S /var/run/docker.sock ]
then
	echo "$prog: there are no running docker" >&2
	exit 2
fi

cd "$(dirname "$0")" || exit
PATH=$(pwd):$PATH
plugin=mackerel-plugin-mysql
if ! which "$plugin" >/dev/null
then
	echo "$prog: $plugin is not installed" >&2
	exit 2
fi

docker compose up -d
trap 'docker compose down; exit 1' 1 2 3 15
sleep 20

password=passpass
sourceport=3307
replicaport=3307

# to store previous value to calculate a diff of metrics
$plugin -password $password -port $replicaport >/dev/null 2>&1
sleep 1

$plugin -password $password -port $replicaport | graphite-metric-test -f rule.txt
status=$?

docker compose down
exit $status
