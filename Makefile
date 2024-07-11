.PHONY: help
help:
	@echo 'test               - run all the tests for all the supported shells'
	@echo 'test_zsh           - run all the tests for Zsh'
	@echo 'test_bash          - run all the tests for Bash'
	@echo 'test_all_in_ubuntu - run all the tests for all the supported shells in Ubuntu'
	@echo 'lint               - run linters and code format checkers'

.PHONY: lint
lint:
	./bin/shellcheck $(filter-out $@,$(MAKECMDGOALS))

.PHONY: test
test:
	./tests/test_all $(filter-out $@,$(MAKECMDGOALS))

.PHONY: test_zsh
test_zsh:
	./tests/test_zsh $(filter-out $@,$(MAKECMDGOALS))

.PHONY: test_bash
test_bash:
	./tests/test_bash $(filter-out $@,$(MAKECMDGOALS))

.PHONY: test_all_in_ubuntu
test_all_in_ubuntu:
	./tests/test_all_in_ubuntu $(filter-out $@,$(MAKECMDGOALS))
