#!/bin/sh

. ./test/unittest.sh
. ./test/tap.sh

plan 14

cat <<'MOCK' >"$SSH"
#!/bin/sh
. ./test/tap.sh
next_test_number=1
note 'ssh args:' "$@"
is "$1", 'foo',                        'ssh: correct hostname'
is "$2", "-L$socket:/run/docker.sock", 'ssh: local port forwarding flag'
is "$3", '-oControlPath=none',         'ssh: disable control path option'
is "$4", '-oConnectTimeout=15',        'ssh: connection timeout option'
is "$5", '-nNT',                       'ssh: terminal and other flags'
perl -MIO::Socket::UNIX \
    -e 'IO::Socket::UNIX->new(Type => SOCK_STREAM, Local => $ENV{socket}, Listen => 1)'
MOCK
chmod +x "$SSH"

cat <<'MOCK' >"$SHELL"
#!/bin/sh
. ./test/tap.sh
next_test_number=6
note 'shell args:' "$@"
is "$1"                        "bar"            "shell: first shell arg is correct"
is "$2"                        "baz"            "shell: second shell arg is correct"
is "$DOCKER_HOST"              "unix://$socket" "shell: DOCKER_HOST is correct"
is "$DOCKER_CONNECT_HOSTNAME"  "foo"            "shell: DOCKER_CONNECT_HOSTNAME is correct"
is "$DOCKER_CONNECT_SOCKET"    "$socket"        "shell: DOCKER_CONNECT_SOCKET is correct"
ok '-n "$DOCKER_CONNECT_PID"'  "shell: DOCKER_CONNECT_PID is set"
ok '-z "$DOCKER_MACHINE_NAME"' "shell: DOCKER_MACHINE_NAME is unset"
ok '-z "$DOCKER_CERT_PATH"'    "shell: DOCKER_CERT_PATH is unset"
ok '-z "$DOCKER_TLS_VERIFY"'   "shell: DOCKER_TLS_VERIFY is unset"
MOCK
chmod +x "$SHELL"

export DOCKER_MACHINE_NAME="qux"
export DOCKER_CERT_PATH="/somewhere"
export DOCKER_TLS_VERIFY=1

./bin/docker-connect -qqq foo bar baz

