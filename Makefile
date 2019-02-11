.PHONY: all
all: dependencies installer ## Installs the bin and etc directory files and the dotfiles.

.PHONY: dependencies
dependencies: ## Installs the dependencies for all the tooling.
	pip3 install --user -r requirements.txt

.PHONY: install
install: ## Installs the tooling itself.
	python3 install.py all
