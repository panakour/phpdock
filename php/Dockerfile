ARG PHP_VERSION=8.0
ARG COMPOSER_VERSION=2
ARG COMPOSER_AUTH

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

RUN apk add --no-cache tini zip

# ---------------------------------------- Install / Enable PHP Extensions ---------------------------------------------
ARG PHP_EXTENSIONS
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions ${PHP_EXTENSIONS}


# ------------------------------------------------- Permissions --------------------------------------------------------

# - Clean bundled config/users & recreate them with UID 1000 for docker compatability in dev container.
# - Create composer directories (since we run as non-root later)
RUN deluser --remove-home www-data && adduser -u1000 -D www-data && rm -rf /var/www /usr/local/etc/php-fpm.d/* && \
    mkdir -p /var/www/.composer /app && chown -R www-data:www-data /app /var/www/.composer

# ------------------------------------------------ PHP Configuration ---------------------------------------------------

# Add Default Config
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Add in Base PHP Config
COPY base-php.ini   $PHP_INI_DIR/conf.d

# ---------------------------------------------- PHP FPM Configuration -------------------------------------------------

# PHP-FPM config
COPY fpm.conf  /usr/local/etc/php-fpm.d/


# --------------------------------------------------- Scripts ----------------------------------------------------------

COPY scripts/*-base          \
     scripts/healthcheck-*   \
     scripts/command-loop    \
     # to
     /usr/local/bin/

RUN  chmod +x /usr/local/bin/*-base /usr/local/bin/healthcheck-* /usr/local/bin/command-loop

# ---------------------------------------------------- Composer --------------------------------------------------------

COPY --from=composer /usr/bin/composer /usr/bin/composer

# ----------------------------------------------------- MISC -----------------------------------------------------------

WORKDIR "/var/www"
USER www-data

# Common PHP Frameworks Env Variables
ENV APP_ENV prod
ENV APP_DEBUG 0

# Validate FPM config (must use the non-root user)
RUN php-fpm -t

# ---------------------------------------------------- HEALTH ----------------------------------------------------------

HEALTHCHECK CMD ["healthcheck-fpm"]

# -------------------------------------------------- ENTRYPOINT --------------------------------------------------------

ENTRYPOINT ["entrypoint-base"]
CMD ["php-fpm"]

## ======================================================================================================================
## ==============================================  PRODUCTION IMAGE  ====================================================
##                                                   --- PROD ---
## ======================================================================================================================

###########################################################################
# install composer runtime dependinces and install app dependinces:
###########################################################################
FROM composer as vendor

ARG PHP_VERSION
ARG COMPOSER_AUTH
# A Json Object with remote repository token to clone private Repos with composer
# Reference: https://getcomposer.org/doc/03-cli.md#composer-auth
ENV COMPOSER_AUTH $COMPOSER_AUTH

# Copy Dependencies files
COPY app/composer.json composer.json
COPY app/composer.lock composer.lock

# Set PHP Version of the Image
RUN composer config platform.php ${PHP_VERSION}

# Install Dependeinces
RUN composer install -n --no-progress --ignore-platform-reqs --no-dev --prefer-dist --no-scripts --no-autoloader


FROM base AS app

USER root

###########################################################################
# Prod Scripts/Configs:
###########################################################################
COPY scripts/*-prod /usr/local/bin/
RUN  chmod +x /usr/local/bin/*-prod
COPY prod-*   $PHP_INI_DIR/conf.d/

###########################################################################
# Final Touch:
###########################################################################
USER www-data
# Copy Vendor
COPY --chown=www-data:www-data --from=vendor /app/vendor /app/vendor
# Copy App Code
COPY --chown=www-data:www-data . .
# Run Composer Install
RUN post-build-prod
ENTRYPOINT ["entrypoint-prod"]
CMD ["php-fpm"]

# ======================================================================================================================
# ==============================================  DEVELOPMENT IMAGE  ===================================================
#                                                   --- DEV ---
# ======================================================================================================================

FROM base as app-dev

ENV APP_ENV dev
ENV APP_DEBUG 1

# Switch root to install stuff
USER root


###########################################################################
# Add some dev stuff:
###########################################################################
RUN apk add git openssh vim;


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
COPY scripts/*-dev /usr/local/bin/
RUN  chmod +x /usr/local/bin/*-dev
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY dev-*   $PHP_INI_DIR/conf.d/


###########################################################################
# Final Touch:
###########################################################################
USER www-data
ENTRYPOINT ["entrypoint-dev"]
CMD ["php-fpm"]