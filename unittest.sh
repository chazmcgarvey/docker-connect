
temp=$(mktemp -d 2>/dev/null || mktemp -d -t 'test')

export DOCKER_CONNECT_UNIT_TEST=1
export SHELL="$temp/mockshell"
export SSH="$temp/mockssh"
export socket="$temp/test.sock"
export DOCKER_CONNECT_SOCKET="$socket"

cleanup() {
    rm -rf "$temp"
}

trap cleanup EXIT

cat <<'MOCK' >"$SSH"
#!/bin/sh
perl -MIO::Socket::UNIX \
    -e 'IO::Socket::UNIX->new(Type => SOCK_STREAM, Local => $ENV{socket}, Listen => 1)'
MOCK
chmod +x "$SSH"

cat <<'MOCK' >"$SHELL"
#!/bin/sh
MOCK
chmod +x "$SHELL"

make_socket() {
    SOCKET=$1 perl -MIO::Socket::UNIX \
        -e 'IO::Socket::UNIX->new(Type => SOCK_STREAM, Local => $ENV{SOCKET}, Listen => 1)'
}

