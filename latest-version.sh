#!/bin/sh
cur="$(dirname $0)"
cd $cur
cat CHANGELOG.md |head -1 |sed  's/^## \(.*\)/\1/'