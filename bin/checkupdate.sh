#!/bin/bash

set -e
. $(dirname $0)/common.sh

fetch_source githubchecker https://github.com/zehome/githubchecker/releases/download/1.1/

chmod +x githubchecker
./githubchecker $@
