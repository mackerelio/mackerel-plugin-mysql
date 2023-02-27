#!/bin/sh

set -eu

cd $(dirname "$0")

mkdir -p bin
export GOBIN="$(pwd)/bin"
export PATH=$GOBIN:$PATH
go install github.com/lufia/graphitemetrictest/cmd/graphite-metric-test@latest
go build -o "$GOBIN/mackerel-plugin-mysql" github.com/mackerelio/mackerel-plugin-mysql

runtest()
{
	local d=$(dirname "$1")
	local f=$(basename "$1")
	(cd "$d" && ./"$f")
}

failtests=0
for i in tests/*/test.sh
do
	if runtest "$i"
	then
		echo "$i: OK"
	else
		echo "$i: FAIL"
		failtests=1
	fi
done
exit $failtests
