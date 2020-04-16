dir=${CURDIR}

# default is test enviroment
env=dev

# dev
project=-p funclub-$(env)-laravel
container=funclub-$(env)-laravel
supervisord=funclub-$(env)-supervisord

build:
	docker-compose -f docker-compose-$(env).yml build

build-no-cache:
	docker-compose -f docker-compose-$(env).yml build --no-cache

start:
	docker-compose -f docker-compose-$(env).yml $(project) up -d

stop:
	docker-compose -f docker-compose-$(env).yml $(project) down


restart: stop start

deploy: npm-install npm-prod composer-install-prod restart

ssh:
	docker-compose  -f docker-compose-$(env).yml $(project) exec $(container) sh

ssh-supervisord:
	docker-compose  -f docker-compose-$(env).yml $(project) exec $(supervisord) sh

exec:
	docker-compose -f docker-compose-$(env).yml $(project) exec -T $(container) $$cmd

info:
	make exec cmd="php artisan --version"
	make exec cmd="php --version"

logs:
	docker logs -f $(container)

logs-supervisord:
	docker logs -f $(supervisord)

drop-migrate:
	make exec cmd="php artisan migrate:fresh"

migrate-prod:
	make exec cmd="php artisan migrate --force"

migrate:
	make exec cmd="php artisan migrate --force"

seed:
	make exec cmd="php artisan db:seed --force"

env:
	make exec cmd="cp ./.env ./.env"


