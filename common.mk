# This file is included in both Makefile.local & Makefile.ci.

SRC := $(shell find transformer/ -name '*.py' ! -name 'test_*' ! -name 'builders_*' ! -name 'conftest.py')
DIST := pyproject.toml poetry.lock

# Runs "poetry install" if pyproject.toml or poetry.lock have changed.
.PHONY: configure
configure: .make/configure

.make/configure: $(DIST)
	poetry install -E docs
	mkdir -p .make && touch .make/configure

# Runs pytest with coverage reporting.
.PHONY: unittest
unittest: configure
	poetry run pytest --failed-first --cov-config .coveragerc --cov-report xml --cov=. tests/transformer/ tests/plugins/
	poetry run pytest --failed-first update-version.py

.PHONY: functest
functest: configure
	$(MAKE) -C tests/functional/

.PHONY: functest
test: unittest functest

.PHONY: lint
lint: black flake8 check-readme

.PHONY: flake8
flake8: configure
	poetry run flake8 $(SRC)

.PHONY: clean
clean:
	rm -rf .make .pytest_cache __pycache__ dist .hypothesis har_transformer.egg-info

.PHONY: check-readme
check-readme: configure
	poetry run python -m readme_renderer README.rst -o /dev/null
