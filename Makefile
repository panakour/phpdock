uplocal:
	docker-compose up -d --build
upprod:
	docker-compose -f docker-compose.prod.yml up -d
upwithphp7.1:
	docker-compose -f docker-compose.yml -f docker-compose.extras.yml up -d php-fpm7.3
