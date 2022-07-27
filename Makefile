.DEFAULT_GOAL:=help
include .env
BIN_PATH_FOLDER = cd ./.docker/bin &&

ifneq ("$(wildcard .env.local)", "")
    include .env.local
else ifneq ("$(wildcard .env)", "")
    include .env
else
error:
$(error .env or .env.local file not found.)
endif

##@ ✨ Cleanup

.PHONY: clean

clean: ## Cleanup the project folders (sudo)
	rm -Rf html

##@ 🪛  Setup environmment

.PHONY: project.certificates.generate project.new.symfony

project.certificates.generate: project.certificates.generate ## Generate a new certificat
	$(BIN_PATH_FOLDER) ./generate_certs.sh $(DOMAIN_NAME) $(MKCERT_VERSION)

project.new.symfony: project.new.symfony ## Create a new symfony project
	docker-compose run backend symfony new . --version="$(SYMFONY_VERSION)" --no-interaction --no-git && docker-compose restart backend
	make composer.add.symfony
	make composer.add.phpstan
	make composer.add.csfixer
	make composer.add.security-advisories
	make composer.add.psalm

project.install: project.install ## First install (sudo)
	sed -i "s/DOMAIN_TO_CHANGE/$(DOMAIN_NAME)/g" ./.docker/config/apache/000-default.conf
	sudo echo "127.0.0.1  $(DOMAIN_NAME)" >> /etc/hosts && make certificates.generate && docker-compose up -d --force-recreate

##@ ⚙️  Composer

composer.add.phpstan: composer.add.phpstan ## Add PHPStan
	docker-compose run backend composer require --dev phpstan/phpstan

composer.add.csfixer: composer.add.csfixer ## Add php-cs-fixer
	docker-compose run backend composer require friendsofphp/php-cs-fixer

composer.add.security-advisories: composer.add.security-advisories ## Add security advisories
	docker-compose run backend composer require --dev roave/security-advisories:dev-latest

composer.add.psalm: composer.add.psalm ## Add psalm
	docker-compose run backend composer require --dev vimeo/psalm

##@ Helpers

.PHONY: help

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[.a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
