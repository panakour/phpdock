uplocal:
	docker-compose -f docker-compose.yml -f docker-compose.local.yml -f docker-compose.extras.yml up -d --build
upprod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
