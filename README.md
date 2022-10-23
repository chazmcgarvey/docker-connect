# NAME

docker-connect - Easily connect to Docker sockets over SSH

# VERSION

Version 0.82.2

# SYNOPSIS

    docker-connect HOSTNAME [SHELL_ARGS]...

    # launch a new shell wherein docker commands go to staging-01.acme.tld
    docker-connect staging-01.acme.tld

    # list the docker processes running on staging-01.acme.tld
    docker-connect staging-01.acme.tld -c 'docker ps'

    # connect as a specific user and a specific port
    docker-connect myusername@staging-01.acme.tld:2222

# DESCRIPTION

This script provides an alternative to Docker Machine for connecting your Docker client to a remote
Docker daemon. Instead of connecting directly to a Docker daemon listening on an external TCP port,
this script sets up a connection to the UNIX socket via SSH.

The main use case for this is when dealing with "permanent" app servers in an environment where you
have a team of individuals who all need access.

Machine doesn't have a great way to support multiple concurrent users. You can add an existing
machine to which you have SSH access using the generic driver on your computer, but if your
colleague does the same then Machine will regenerate the Docker daemon TLS certificates, replacing
the ones Machine set up for you.

Furthermore, the Docker daemon relies on TLS certificates for client authorization, which is all
fine and good, but organizations are typically not as prepared to deal with the management of client
TLS certificates as they are with the management of SSH keys. Worse, the Docker daemon doesn't
support certificate revocation lists! So if a colleague leaves, you must replace the certificate
authority and recreate and distribute certificates for each remaining member of the team. Ugh!

Much easier to just use SSH for authorization.

To be clear, this script isn't a full replacement for Docker Machine. For one thing, Machine has
a lot more features and can actually create machines. This script just assists with a particular
workflow that is currently underserved by Machine.

# HOW IT WORKS

What this script actually does is something similar to this sequence of commands:

    ssh -L$PWD/docker.sock:/run/docker.sock $REMOTE_USER@$REMOTE_HOST -p$REMOTE_PORT -nNT &
    export DOCKER_HOST="unix://$PWD/docker.sock"
    unset DOCKER_CERT_PATH
    unset DOCKER_TLS_VERIFY

This uses [ssh(1)](http://man.he.net/man1/ssh) to create a UNIX socket that forwards to the Docker daemon's own UNIX socket on
the remote host. The benefit that `docker-connect` has over executing these commands directly is
`docker-connect` doesn't require write access to the current directory since it puts its sockets in
`$TMPDIR` (typically `/tmp`).

If your local system doesn't support UNIX sockets, you could use the following `ssh` command
instead which uses a TCP socket:

    ssh -L2000:/run/docker.sock $REMOTE_USER@$REMOTE_HOST -p$REMOTE_PORT -nNT &
    export DOCKER_HOST="tcp://localhost:2000"

An important drawback here is that any local user on the machine will then have unchallenged access
to the remote Docker daemon by just connecting to localhost:2000. But this may be a reasonable
alternative for use on non-multiuser machines only.

# REQUIREMENTS

- a Bourne-compatible, POSIX-compatible shell

    This program is written in shell script.

- [OpenSSH](https://www.openssh.com) 6.7+

    Needed to make the socket connection.

- [Docker](https://www.docker.com) client

    Not technically required, but this program isn't useful without it.

# INSTALL

Install from the internet using &lt;curl(1)>:

    # Assuming you have "$HOME/bin" in your $PATH:
    curl -Lo ~/bin/docker-connect \
      https://raw.githubusercontent.com/chazmcgarvey/docker-connect/master/bin/docker-connect
    chmod +x ~/bin/docker-connect

Install from a checked-out repo:

    git clone https://github.com/chazmcgarvey/docker-connect.git
    cd docker-connect
    sudo make install   # install to /usr/local

# ENVIRONMENT

The following environment variables may affect or will be set by this program:

- `DOCKER_CONNECT_SOCKET`

    The absolute path to the local socket.

- `DOCKER_CONNECT_HOSTNAME`

    The hostname of the remote peer.

- `DOCKER_CONNECT_PID`

    The process ID of the SSH process maintaining the connection.

- `DOCKER_HOST`

    The URI of the local socket.

# TIPS

If you run many shells and connections, having the hostname of the host that the Docker client is
connected to in your prompt may be handy. Try something like this in your local shell config file:

    if [ -n "$DOCKER_CONNECT_HOSTNAME" ]
    then
        PS1="[docker:$DOCKER_CONNECT_HOSTNAME] $PS1"
    fi

# AUTHOR

Charles McGarvey <chazmcgarvey@brokenzipper.com>

# LICENSE

This software is copyright (c) 2018 by Charles McGarvey.

This is free software, licensed under:

    The MIT (X11) License
