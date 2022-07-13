
include .env
BIN_PATH_FOLDER = cd ./.docker/bin &&

## —— Commands 🪛 ————————————————————————————————————————————————————————————————
certificates.generate: ## Generate a new certificat
	$(BIN_PATH_FOLDER) ./generate_certs.sh

install: ## First install
	sudo echo "127.0.0.1  sefu.test" >> /etc/hosts && make certificates.generate

create.symfony.project: ## Create a new symfony project
	docker-compose run backend symfony new . --version="$(SYMFONY_VERSION)" --no-interaction

.PHONY: help

help: ## Display this help
	@grep -E '^[.a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-8s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
