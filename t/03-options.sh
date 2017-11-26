#!/bin/sh

. ./unittest.sh
. ./tap.sh

plan 3

./docker-connect -h |grep 'OPTIONS' >/dev/null 2>&1
is "$?" 0 'the -h flag works'

./docker-connect -v |grep '^docker-connect [[:digit:]]' >/dev/null 2>&1
is "$?" 0 'the -v flag works'

./docker-connect -Z foo 2>/dev/null
is "$?" 1 'invalid option correctly fails'

