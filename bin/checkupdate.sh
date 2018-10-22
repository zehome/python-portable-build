#!/bin/bash

wget -c https://github.com/zehome/githubchecker/releases/download/1.1/githubchecker
chmod +x githubchecker
./githubchecker $@
