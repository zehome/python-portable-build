MATCH ?= >=3.12,<3.13
VERSION ?= $(shell bin/checkupdate.sh -owner python -repository cpython -match "$(MATCH)" -quiet)
PGO_ENABLED ?= 0

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
