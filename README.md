Build portable (shared) in a "portable" maner
=============================================

[![Build Status](https://travis-ci.org/zehome/python-portable-build.svg?branch=master)](https://travis-ci.org/zehome/python-portable-build)

Helps create a (slim) python build, without the need to specify **PATH**
or **LD_LIBRARY_PATH**.

Uses patchelf to set rpath relative to '$ORIGIN'.

Python executable scripts are patched to have a dynamic sheebang in order to call
the right python. (**needs perl**)


