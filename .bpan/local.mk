ifndef BPAN_ROOT
    BPAN_ROOT := not/a/bpan/root
    BPAN_CMDS :=
endif

PREFIX  ?= /usr/local

PROVE           := prove
POD2MARKDOWN    := pod2markdown

ifdef V
    v := $V
endif

all:: docs

docs:: README.md

install::
	cp -a bin/docker-connect $(PREFIX)/bin/docker-connect

uninstall::
	$(RM) $(PREFIX)/bin/docker-connect

README.md:: bin/docker-connect
	$(POD2MARKDOWN) $< $@

.PHONY: all docs install uninstall
