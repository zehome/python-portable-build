Build portable (shared) in a "portable" maner
=============================================

Helps create a (slim) python build, without the need to specify **PATH**
or **LD_LIBRARY_PATH**.

Uses patchelf to set rpath relative to '$ORIGIN'.

Python executable scripts are patched to have a dynamic sheebang in order to call
the right python. (**needs perl**)

