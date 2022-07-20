.DEFAULT_GOAL:=help
include .env
BIN_PATH_FOLDER = cd ./.docker/bin &&

##@ ✨ Cleanup

.PHONY: clean

clean: ## Cleanup the project folders (sudo)
	rm -Rf html

##@ 🪛  Setup environmment

.PHONY: install certificate project

certificates.generate: certificate ## Generate a new certificat
	$(BIN_PATH_FOLDER) ./generate_certs.sh $(DOMAIN_NAME) $(MKCERT_VERSION)

create.symfony.project: project ## Create a new symfony project
	docker-compose run backend symfony new . --version="$(SYMFONY_VERSION)" --no-interaction --no-git && docker-compose restart backend

install: install ## First install (sudo)
	sed -i "s/DOMAIN_TO_CHANGE/$(DOMAIN_NAME)/g" ./.docker/config/apache/000-default.conf
	sudo echo "127.0.0.1  $(DOMAIN_NAME)" >> /etc/hosts && make certificates.generate && docker-compose up -d --force-recreate

##@ Helpers

.PHONY: help

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[.a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
