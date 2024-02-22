.PHONY: build
build:
	go build -o mackerel-plugin-mysql

.PHONY: test
test: testgo build testci

.PHONY: testci
testci:
	go install github.com/lufia/graphitemetrictest/cmd/graphite-metric-test@latest
	./test.sh

.PHONY: testgo
testgo:
	go test -v ./...

