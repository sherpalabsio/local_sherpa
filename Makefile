.PHONY: lint
lint:
	./bin/shellcheck $(filter-out $@,$(MAKECMDGOALS))

.PHONY: help
help:
	@echo 'lint - run linters and code format checkers'
