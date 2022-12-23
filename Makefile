MATCH ?= >=3.11,<3.12
VERSION ?= $(shell bin/checkupdate.sh -owner python -repository cpython -match "$(MATCH)" -quiet)
PGO_ENABLED ?= 1

all: build

ci:
	docker build -t zehome/python-portable-build .

clean:
	rm -rf build

build:
	echo "Match: $(MATCH)"
	echo "Version: $(VERSION)"
	([ -d build ] || mkdir build; cd build; bash -x ../bin/openssl.sh && bash -x ../bin/build.sh "${VERSION}")

.PHONY: build clean ci
