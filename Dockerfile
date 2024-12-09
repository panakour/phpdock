ARG PHP_VERSION="8.4"
ARG COMPOSER_VERSION=2
ARG COMPOSER_AUTH
ARG NGINX_VERSION=1.27
ARG APP_CODE_PATH="."

# -------------------------------------------------- Composer Image ----------------------------------------------------

FROM composer:${COMPOSER_VERSION} as composer

# ======================================================================================================================
#                                                   --- Base ---
# ---------------  This stage install needed extenstions, plugins and add all needed configurations  -------------------
# ======================================================================================================================

FROM php:${PHP_VERSION}-fpm-alpine AS base

# Maintainer label
LABEL maintainer="panakourweb@gmail.com"

# pipefail. add the ability to pipe the output of a fail command. https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# ------------------------------------- Install Packages Needed Inside Base Image --------------------------------------

RUN apk add --no-cache tini zip fcgi

# ---------------------------------------- Install / Enable PHP Extensions ---------------------------------------------
ARG PHP_EXTENSIONS
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions ${PHP_EXTENSIONS}

# ------------------------------------------------ PHP Configuration ---------------------------------------------------

# Add Default Config
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Add in Base PHP Config
COPY phpdock/php/base-php.ini   $PHP_INI_DIR/conf.d

# ---------------------------------------------- PHP FPM Configuration -------------------------------------------------

# PHP-FPM config
COPY phpdock/php/fpm.conf  /usr/local/etc/php-fpm.d/

# --------------------------------------------------- Scripts ----------------------------------------------------------

COPY phpdock/php/scripts/*-base          \
     phpdock/php/scripts/php-fpm-healthcheck   \
     # to
     /usr/local/bin/

RUN  chmod +x /usr/local/bin/*-base /usr/local/bin/php-fpm-healthcheck

# ---------------------------------------------------- Composer --------------------------------------------------------

COPY --from=composer /usr/bin/composer /usr/bin/composer

# ----------------------------------------------------- MISC -----------------------------------------------------------

WORKDIR ${APP_CODE_PATH_CONTAINER}

RUN php-fpm -t

# ---------------------------------------------------- HEALTH ----------------------------------------------------------

HEALTHCHECK CMD ["php-fpm-healthcheck"]

# -------------------------------------------------- ENTRYPOINT --------------------------------------------------------

ENTRYPOINT ["entrypoint-base"]
CMD ["php-fpm"]


FROM base as php-dev

ENV APP_ENV dev
ENV APP_DEBUG 1

###########################################################################
# Add some dev stuff:
###########################################################################
RUN apk add git openssh vim github-cli;

###########################################################################
# xdebug
###########################################################################
# For Xdebuger to work, it needs the docker host ID
# - in Mac AND Windows, `host.docker.internal` resolve to Docker host IP
# - in Linux, `172.17.0.1` is the host IP
ENV XDEBUG_CLIENT_HOST=172.17.0.1
ENV XDEBUG_IDE_KEY=myide
ENV PHP_IDE_CONFIG="serverName=${XDEBUG_IDE_KEY}"
RUN install-php-extensions xdebug

###########################################################################
# Dev Scripts/Configs:
###########################################################################
COPY phpdock/php/scripts/*-dev /usr/local/bin/
RUN  chmod +x /usr/local/bin/*-dev
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY phpdock/php/dev-*   $PHP_INI_DIR/conf.d/

###########################################################################
# Final Touch:
###########################################################################
ENTRYPOINT ["entrypoint-dev"]
CMD ["php-fpm"]

# ======================================================================================================================
# ======================================================================================================================
#                                                  --- NGINX ---
# ======================================================================================================================
# ======================================================================================================================
FROM nginx:${NGINX_VERSION}-alpine AS nginx

COPY phpdock/nginx/nginx-*   /usr/local/bin/
COPY phpdock/nginx/          /etc/nginx/
RUN chmod +x /usr/local/bin/nginx-*

ENV PHP_FPM_HOST "localhost"
ENV PHP_FPM_PORT "9000"

ENTRYPOINT ["nginx-entrypoint"]

EXPOSE 80 443

COPY phpdock/nginx/dev/*.conf   /etc/nginx/conf.d/
COPY phpdock/nginx/dev/certs/   /etc/nginx/certs/
COPY phpdock/nginx/sites/       /etc/nginx/sites-available