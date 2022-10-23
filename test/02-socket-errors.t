#!/bin/sh

. ./test/unittest.sh
. ./test/tap.sh

plan 3

make_socket "$socket"

DOCKER_CONNECT_HOSTNAME=foo ./bin/docker-connect -qqq foo
is "$?" 2 'socket already exists and environment is configured'

./bin/docker-connect -qqq foo
is "$?" 3 'socket already exists'

rm -f "$socket"

cat <<'MOCK' >"$SSH"
#!/bin/sh
exit 1
MOCK
chmod +x "$SSH"

./bin/docker-connect -qqq foo
is "$?" 5 'socket connection error'

