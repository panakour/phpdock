CMD_PREFIX := DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1

uplocal:
	${CMD_PREFIX} docker compose -f docker-compose.yml -f docker-compose.extras.yml up -d php-fpm nginx mariadb php-fpm7.3 php-fpm7.4 php-fpm8.0 php-fpm8.1 php-fpm8.2 memcached mailpit redis elasticsearch
upprod:
	${CMD_PREFIX} docker compose -f docker-compose.prod.yml up -d --build
