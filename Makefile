.PHONY: help
help:
	@echo "lint                    - run linters and code format checkers"
	@echo "test                    - run all the tests for all the supported shells"
	@echo "test_zsh                - run all the tests for Zsh"
	@echo "test_bash               - run all the tests for Bash"
	@echo "test_all_in_ubuntu      - run all the tests for all the supported shells in Ubuntu"
	@echo "test_min_shell_versions - run all test for the all minimum supported shell versions in Ubuntu"
	@echo "test_performance        - run a benchmark test for all the supported shells"
	@echo "test_install_local      - create a fresh build and install it locally via Homebrew"
	@echo "test_install_online     - test installing the last release via Homebrew and GitHub"
	@echo "test_update_version     - test upgrading to the latest version"
	@echo "dist                    - package the project into a tarball"
	@echo "release                 - create a new release, tag it, and push to GitHub"
	@echo "release_override        - override the existing release, tag it, and push to GitHub"

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

.PHONY: test_min_shell_versions
test_min_shell_versions:
	./tests/test_min_shell_versions $(filter-out $@,$(MAKECMDGOALS))

.PHONY: test_performance
test_performance:
	./tests/performance/harness $(filter-out $@,$(MAKECMDGOALS))

.PHONY: test_install_local
test_install_local:
	./tests/install/local_build/test_runner

.PHONY: test_install_online
test_install_online:
	./tests/install/online/test_runner

.PHONY: test_update_version
test_update_version:
	./tests/install/update/test_runner

.PHONY: dist
dist:
	@rm -rf dist
	@mkdir -p dist/local_sherpa_$$SHERPA_VERSION
	@cp -r lib bin init LICENSE README.md dist/local_sherpa_$$SHERPA_VERSION
	@rm -f dist/local_sherpa_$$SHERPA_VERSION/bin/shellcheck
	@cd dist && tar --no-xattrs -czf local_sherpa_$$SHERPA_VERSION.tar.gz local_sherpa_$$SHERPA_VERSION
	@printf "sha256: "
	@sha256sum dist/local_sherpa_$$SHERPA_VERSION.tar.gz | awk '{print $$1}'

.PHONY: release
release:
	@if git rev-parse "v$(SHERPA_VERSION)" >/dev/null 2>&1; then \
		echo "Error: Tag v$(SHERPA_VERSION) already exists."; \
		exit 1; \
	fi
	$(MAKE) dist
	@git tag -a v$(SHERPA_VERSION) -m "Release version $(SHERPA_VERSION)"
	@git push origin v$(SHERPA_VERSION)
	@gh release create v$(SHERPA_VERSION) dist/local_sherpa_$(SHERPA_VERSION).tar.gz --title "v$(SHERPA_VERSION)" --latest --notes ""

.PHONY: release_override
release_override: dist
	@git tag -a -f v$(SHERPA_VERSION) -m "Release version $(SHERPA_VERSION)"
	@git push origin v$(SHERPA_VERSION) -f
	-@gh release delete v$(SHERPA_VERSION) -y
	@gh release create v$(SHERPA_VERSION) dist/local_sherpa_$(SHERPA_VERSION).tar.gz --title "v$(SHERPA_VERSION)" --latest --notes ""

.PHONY: uninstall_locally
uninstall_locally:
	@rm -rf ~/.local/lib/local_sherpa_* ~/.local/bin/local_sherpa_init

.PHONY: install_locally
install_locally: dist uninstall_locally
	@cp -r dist/local_sherpa_$(SHERPA_VERSION) ~/.local/lib/local_sherpa_$(SHERPA_VERSION)
	@ln -sf ~/.local/lib/local_sherpa_$(SHERPA_VERSION)/init ~/.local/bin/local_sherpa_init
