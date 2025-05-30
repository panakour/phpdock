# [DEPRECATED] in favor of nix

## PHPDock

PHPDock is a Docker-based development environment for PHP applications. It simplifies the setup and management of PHP development environments by using Docker containers.

## Features
- Supports multiple PHP versions at the same time.
- Easily add the PHP extensions you want.
- Xdebug.
- A lot of extra services in the Docker Compose.

## Requirements

- Docker
- Docker Compose

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/panakour/phpdock.git
   cd phpdock
   ```
2. Copy the example environment file and customize it: e.g. modify the PHP extensions you want using the PHP_EXTENSIONS variable.
   ```sh
   cp .env.example .env
   ```

4. Create the nginx site in the path: nginx/sites/* e.g you can copy the [the example laravel conf](nginx/sites/laravel.conf.example) and modify to your own if you want to use diferent than the defailt php version can modify fastcgi_pass to the fpm you want e.g **php-fpm7.3:9000** 
5. Build and start the Docker containers (in the below example, you will have the default PHP FPM version, MariaDB, PHP 7.4, and nginx):
   ```sh
   docker compose -f docker-compose.yml -f docker-compose.extras.yml up -d php-fpm nginx mariadb php-fpm7.4
   ```
