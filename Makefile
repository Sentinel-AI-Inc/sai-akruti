# Makefile for Poetry projects
# ---- Config ---------------------------------------------------------------
REPOSITORY ?= pypi           # or: testpypi
DIST_DIR   ?= dist
POETRY 	   := $(HOME)/.local/bin/poetry
VERSION    := $(shell $(POETRY) version -s)

REPOSITORY := $(strip $(REPOSITORY))

# ---- Phony targets --------------------------------------------------------
.PHONY: help clean check build publish publish-test release version \
        bump-patch bump-minor bump-major tag repo-test-setup login-pypi login-testpypi

help: ## Show this help
	@awk 'BEGIN{FS=":.*##"; printf "\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*##/ { printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST); \
	echo ""; \
	echo "Variables:"; \
	echo "  REPOSITORY=pypi|testpypi (default: pypi)"

clean: ## Remove build artifacts
	rm -rf $(DIST_DIR) build *.egg-info

check: ## Validate pyproject & lockfile
	$(POETRY) check

build: clean check ## Build sdist & wheel into ./dist
	$(POETRY) build

publish: build ## Publish to $(REPOSITORY) (requires Poetry token/config)
ifeq ($(REPOSITORY),pypi)
	$(POETRY) publish
else
	$(POETRY) publish -r $(REPOSITORY)
endif

publish-test: ## Build & publish to TestPyPI
	$(MAKE) publish REPOSITORY=testpypi

release: ## Build, publish to $(REPOSITORY), tag & push
	$(MAKE) publish REPOSITORY=$(REPOSITORY)
	$(MAKE) tag

version: ## Print project version
	@echo $(VERSION)

bump-patch: ## Bump patch version (x.y.Z)
	$(POETRY) version patch
	@echo "New version: $$(poetry version -s)"

bump-minor: ## Bump minor version (x.Y.0)
	$(POETRY) version minor
	@echo "New version: $$(poetry version -s)"

bump-major: ## Bump major version (X.0.0)
	$(POETRY) version major
	@echo "New version: $$(poetry version -s)"

tag: ## Create and push git tag v$(VERSION)
	git tag -a v$(VERSION) -m "Release v$(VERSION)"
	git push --follow-tags

# ---- Optional helpers -----------------------------------------------------

repo-test-setup: ## Add TestPyPI repository to Poetry (one-time)
	$(POETRY) config repositories.testpypi https://test.pypi.org/legacy/

login-pypi: ## Configure PyPI token in Poetry (uses POETRY_PYPI_TOKEN_PYPI)
	@test -n "$$POETRY_PYPI_TOKEN_PYPI" || { echo "Set POETRY_PYPI_TOKEN_PYPI first"; exit 1; }
	$(POETRY) config pypi-token.pypi "$$POETRY_PYPI_TOKEN_PYPI"

login-testpypi: ## Configure TestPyPI token in Poetry (uses POETRY_PYPI_TOKEN_TESTPYPI)
	@test -n "$$POETRY_PYPI_TOKEN_TESTPYPI" || { echo "Set POETRY_PYPI_TOKEN_TESTPYPI first"; exit 1; }
	$(POETRY) config pypi-token.testpypi "$$POETRY_PYPI_TOKEN_TESTPYPI"
