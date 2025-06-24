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

password=passpass
port=23306
image=mysql:8
cacert=$(mktemp 'ca.XXXXXXXXXX.pem')

docker run -d \
	--name "test-tls-$plugin" \
	-p $port:3306 \
	-e MYSQL_ROOT_PASSWORD=$password \
	"$image"
trap 'docker stop test-$plugin; docker rm test-$plugin; rm $cacert; exit 1' 1 2 3 15
sleep 10

#export MACKEREL_PLUGIN_WORKDIR=tmp

# wait until bootstrap mysqld..
for i in $(seq 5)
do
	echo "Connecting $i..."
	if $plugin -port $port -password $password -enable_extended >/dev/null 2>&1
	then
		break
	fi
	sleep 3
done
sleep 1

docker cp "test-tls-$plugin:/var/lib/mysql/ca.pem" "$cacert"

$plugin -port $port -password $password -enable_extended \
	--tls --tls-root-cert="$cacert" --tls-skip-verify >/dev/null 2>&1
status=$?
sleep 1

docker stop "test-tls-$plugin"
docker rm "test-tls-$plugin"
rm "$cacert"
exit $status
