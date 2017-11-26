# NAME

docker-connect - Easily connect to Docker sockets over SSH

# VERSION

Version 0.80

# SYNOPSIS

    docker-connect HOSTNAME [SHELL_ARGS]...

    # launch a new shell wherein docker commands go to staging-01.acme.tld
    docker-connect staging-01.acme.tld

    # list the docker processes running on staging-01.acme.tld
    docker-connect staging-01.acme.tld -c 'docker ps'

# DESCRIPTION

This script provides an alternative to Docker Machine for connecting your Docker client to a remote
Docker daemon. Instead of connecting directly to a Docker daemon listening on an external TCP port,
this script sets up a connection to the UNIX socket via SSH.

Why?

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

# REQUIREMENTS

- a Bourne-compatible, POSIX-compatible shell

    This program is written in shell script.

- [OpenSSH](https://www.openssh.com) 6.7+

    Needed to make the socket connection.

- [Docker](https://www.docker.com) client

    Not technically required, but this program isn't useful without it.

# INSTALL

[![Build Status](https://travis-ci.org/chazmcgarvey/docker-connect.svg?branch=master)](https://travis-ci.org/chazmcgarvey/docker-connect)

To install, just copy `docker-connect` into your `PATH` and make sure it is executable.

    # Assuming you have "$HOME/bin" in your $PATH:
    cp docker-connect ~/bin/
    chmod +x ~/bin/docker-connect

# ENVIRONMENT

The following environment variables may affect or will be set by this program:

- `DOCKER_CONNECT_SOCKET`

    The absolute path to the local socket.

- `DOCKER_CONNECT_HOSTNAME`

    The hostname of the remote peer.

- `DOCKER_CONNECT_PID`

    The PID of the SSH process maintaining the connection.

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

This software is copyright (c) 2017 by Charles McGarvey.

This is free software, licensed under:

    The MIT (X11) License
