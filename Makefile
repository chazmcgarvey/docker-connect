
PROVE           = prove
POD2MARKDOWN    = pod2markdown

all:

docs: README.md

test:
	$(PROVE) --ext sh $(if $(V),-v)

README.md: docker-connect
	$(POD2MARKDOWN) "$<" "$@"

.PHONY: all docs test

