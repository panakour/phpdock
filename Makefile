uplocal:
	docker-compose -f docker-compose.yml -f docker-compose.local.yml up -d --build
restartlocal:
	docker-compose -f docker-compose.yml -f docker-compose.local.yml restart
upprod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
