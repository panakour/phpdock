CMD_PREFIX := DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1

uplocal:
	${CMD_PREFIX} docker compose up -d && make run-php7.3 && make run-php7.4 && make run-memcached && make run-mailhog
upprod:
	${CMD_PREFIX} docker compose -f docker-compose.prod.yml up -d --build
run-php7.3:
	${CMD_PREFIX} docker compose -f docker-compose.yml -f docker-compose.extras.yml up -d php-fpm7.3
run-php7.4:
	${CMD_PREFIX} docker compose -f docker-compose.yml -f docker-compose.extras.yml up -d php-fpm7.4
run-memcached:
	${CMD_PREFIX} docker compose -f docker-compose.yml -f docker-compose.extras.yml up -d memcached
run-mailhog:
	${CMD_PREFIX} docker compose -f docker-compose.yml -f docker-compose.extras.yml up -d mailhog
