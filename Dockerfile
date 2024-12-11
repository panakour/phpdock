ARG PHP_VERSION="8.4"
ARG COMPOSER_VERSION=2

FROM composer:${COMPOSER_VERSION} AS composer

FROM php:${PHP_VERSION}-fpm-alpine AS php

LABEL maintainer="panakourweb@gmail.com"

ARG PHP_EXTENSIONS
ARG APP_CODE_PATH="."
ARG APP_CODE_PATH_CONTAINER="/webdata"

ENV APP_ENV=dev \
    APP_DEBUG=1 \
    APP_CODE_PATH_CONTAINER=$APP_CODE_PATH_CONTAINER \
    XDEBUG_CLIENT_HOST=172.17.0.1 \
    XDEBUG_IDE_KEY=myide \
    PHP_IDE_CONFIG="serverName=${XDEBUG_IDE_KEY}"

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache tini zip fcgi vim git openssh curl

# Install PHP extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions ${PHP_EXTENSIONS}

COPY --from=composer /usr/bin/composer /usr/bin/composer

# PHP-FPM config
COPY php/fpm.conf  /usr/local/etc/php-fpm.d/

# Scripts & Healthchecks
COPY php/scripts/entrypoint /usr/local/bin/
COPY php/scripts/php-fpm-healthcheck /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint /usr/local/bin/php-fpm-healthcheck

# Use dev php.ini
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY php/dev-* $PHP_INI_DIR/conf.d/

# Set working directory now that ENV is set
WORKDIR ${APP_CODE_PATH_CONTAINER}

RUN php-fpm -t

HEALTHCHECK CMD ["php-fpm-healthcheck"]

ENTRYPOINT ["entrypoint"]
CMD ["php-fpm"]
