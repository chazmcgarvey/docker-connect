
PROVE           = prove
POD2MARKDOWN    = pod2markdown

all:

docs: README.md

test:
	$(PROVE) $(if $(V),-v) test

README.md: docker-connect
	$(POD2MARKDOWN) "$<" "$@"

.PHONY: all docs test

