.PHONY: all
all: dependencies installer ## Installs the bin and etc directory files and the dotfiles.

.PHONY: dependencies
dependencies: ## Installs the dependencies for all the tooling.
	pip3 install -r requirements.txt

.PHONY: installer
installer: ## Installs the tooling itself.
	python3 install.py all

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif
