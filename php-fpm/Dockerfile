ARG PHP_VERSION=8.0
ARG COMPOSER_VERSION=2
ARG XDEBUG_VERSION=3.1.2
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

# ------------------------------------- Install Packages Needed Inside Base Image --------------------------------------

RUN apk add --no-cache tini zip

# ---------------------------------------- Install / Enable PHP Extensions ---------------------------------------------

RUN apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS  \
		freetype-dev \
		imagemagick-dev \
		libjpeg-turbo-dev \
		libpng-dev \
		libwebp-dev \
		libzip-dev \
		icu-dev \
 # PHP Extensions --------------------------------- \
&& docker-php-ext-configure gd \
 		--with-freetype \
 		--with-jpeg \
 		--with-webp \
 && docker-php-ext-install -j$(nproc) \
        intl \
        pdo_mysql \
        opcache \
        pcntl \
        bcmath \
        zip \
        gd \
 # Pecl Extensions -------------------------------- \
 && pecl install apcu-5.1.20 && docker-php-ext-enable apcu \
 # Cleanup ---------------------------------------- \
 # - Detect Runtime Dependencies of the installed extensions. \
 # - src: https://github.com/docker-library/wordpress/blob/master/latest/php7.4/fpm-alpine/Dockerfile \
 && runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
  # Save Runtime Deps in a virtual deps
	apk add --no-network --virtual .php-extensions-rundeps $runDeps; \
  # Uninstall Everything we Installed (minus the runtime Deps)
	apk del --no-network .build-deps

###########################################################################
# PHP Memcached:
###########################################################################
ARG INSTALL_MEMCACHED=false
RUN if [ ${INSTALL_MEMCACHED} = true ]; then \
    apk add --no-cache --update libmemcached-libs zlib \
    && apk add --no-cache --update --virtual .build-deps zlib-dev libmemcached-dev cyrus-sasl-dev \
    $PHPIZE_DEPS \
    && pecl install memcached \
    && echo "extension=memcached.so" > /usr/local/etc/php/conf.d/20_memcached.ini \
    && apk del -f .build-deps \
;fi

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

FROM base AS app

USER root

###########################################################################
# Prod Scripts/Configs:
###########################################################################
COPY docker/*-prod /usr/local/bin/
RUN  chmod +x /usr/local/bin/*-prod
COPY docker/php/prod-*   $PHP_INI_DIR/conf.d/

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

ARG XDEBUG_VERSION
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
ENV XDEBUG_CLIENT_HOST="172.17.0.1"
RUN apk add --virtual .buildtime-deps ${PHPIZE_DEPS} \
 && pecl install xdebug-${XDEBUG_VERSION} && docker-php-ext-enable xdebug \
 && apk del -f .buildtime-deps


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