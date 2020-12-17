#!/usr/bin/env bash
find src -name \*.moon | while read f ; do echo $f ; moonc -p $f | luamin -c > `echo $f | sed s/moon/lua/` ; done
