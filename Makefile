CMD_PREFIX := DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1

uplocal:
	${CMD_PREFIX} docker compose up -d
upprod:
	${CMD_PREFIX} docker compose -f docker-compose.prod.yml up -d --build
upwithphp7.1:
	${CMD_PREFIX} docker compose -f docker-compose.yml -f docker-compose.extras.yml up -d php-fpm7.3
