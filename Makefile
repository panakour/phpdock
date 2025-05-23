CMD_PREFIX := DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1

nginx_build:
	${CMD_PREFIX} docker compose up -d --build nginx
up:
	${CMD_PREFIX} docker compose -f docker-compose.yml -f docker-compose.extras.yml up -d php-fpm nginx mariadb php-fpm7.4 php-fpm8.0 php-fpm8.1 php-fpm8.2 php-fpm8.3 memcached mailpit redis elasticsearch opensearch elasticsearch8
up_mongo:
	${CMD_PREFIX} docker compose -f docker-compose.yml -f docker-compose.extras.yml up -d mongodb
up_psql:
	${CMD_PREFIX} docker compose -f docker-compose.yml -f docker-compose.extras.yml up -d postgres