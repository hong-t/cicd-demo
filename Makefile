REPO_ROOT	:= $(shell git rev-parse --show-toplevel)

.DEFAULT_GOAL:=help
SHELL:=/usr/bin/env bash

COLOR:=\\033[36m
NOCOLOR:=\\033[0m

##@ init project
init:
	$(shell cp -f .hooks/* .git/hooks)

##@ Verify

.PHONY: add-verify-hook verify verify-build verify-golangci-lint verify-go-mod verify-shellcheck verify-spelling

add-verify-hook: ## Adds verify scripts to git pre-commit hooks.
# Note: The pre-commit hooks can be bypassed by using the flag --no-verify when
# performing a git commit.
	git config --local core.hooksPath "${REPO_ROOT}/.githooks"

# TODO(verify): Reconcile with duplicate target
verify: ## Runs all verification tests.
	${REPO_ROOT}/hack/verify.sh

# TODO(lint): Uncomment verify-shellcheck once we finish shellchecking the repo.
verify: tools verify-build verify-golangci-lint verify-go-mod #verify-shellcheck ## Runs verification scripts to ensure correct execution

verify-build: ## Builds the project for a chosen set of platforms
	${REPO_ROOT}/hack/verify-build.sh

verify-go-mod: ## Runs the go module linter
	${REPO_ROOT}/hack/verify-go-mod.sh

verify-golangci-lint: ## Runs all golang linters
	${REPO_ROOT}/hack/verify-golangci-lint.sh

verify-shellcheck: ## Runs shellcheck
	${REPO_ROOT}/hack/verify-shellcheck.sh

verify-spelling: ## Verifies spelling.
	${REPO_ROOT}/hack/verify-spelling.sh

##@ Tests

.PHONY: test test-go-unit test-go-integration

test: test-go-unit ## Runs unit tests

test-go-unit: ## Runs Golang unit tests
	${REPO_ROOT}/hack/test-go.sh

##@ Tools

.PHONY: tools

WHAT ?= kepctl kepify

tools: ## Installs all KEP tools, can select via e.g. WHAT=kepctl
	./compile-tools $(WHAT)

##@ Dependencies

.SILENT: update-deps update-deps-go
.PHONY:  update-deps update-deps-go

update-deps: update-deps-go ## Update all dependencies for this repo
	echo -e "${COLOR}Commit/PR the following changes:${NOCOLOR}"
	git status --short

update-deps-go: GO111MODULE=on
update-deps-go: ## Update all golang dependencies for this repo
	go get -u -t ./...
	go mod tidy
	go mod verify
	$(MAKE) test-go-unit
	${REPO_ROOT}/hack/update-all.sh

##@ Helpers

.PHONY: help

help:  ## Display this help
	@awk \
		-v "col=${COLOR}" -v "nocol=${NOCOLOR}" \
		' \
			BEGIN { \
				FS = ":.*##" ; \
				printf "\nUsage:\n  make %s<target>%s\n", col, nocol \
			} \
			/^[a-zA-Z_-]+:.*?##/ { \
				printf "  %s%-15s%s %s\n", col, $$1, nocol, $$2 \
			} \
			/^##@/ { \
				printf "\n%s%s%s\n", col, substr($$0, 5), nocol \
			} \
		' $(MAKEFILE_LIST)
