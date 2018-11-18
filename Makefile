.PHONY: all
all: dependencies installer ## Installs the bin and etc directory files and the dotfiles.

.PHONY: dependencies
dependencies: ## Installs the dependencies for all the tooling.
	pip3 install -r requirements.txt

.PHONY: installer
installer: ## Installs the tooling itself.
	python3 install.py all