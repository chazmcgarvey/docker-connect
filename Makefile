PREFIX  ?= /usr/local

PROVE           = prove
POD2MARKDOWN    = pod2markdown

all: docs

docs: README.md

install:
	cp -a bin/docker-connect $(PREFIX)/bin/docker-connect

test:
	$(PROVE) $(if $(V),-v) test

uninstall:
	$(RM) $(PREFIX)/bin/docker-connect

README.md: bin/docker-connect
	$(POD2MARKDOWN) "$<" "$@"

.PHONY: all docs install test uninstall
