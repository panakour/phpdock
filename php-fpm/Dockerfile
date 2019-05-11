ARG PHP_VERSION=${PHP_VERSION}

FROM php:${PHP_VERSION}-fpm-alpine3.9

LABEL maintainer="Panagiotis Koursaris <panakourweb@gmail.com>"

#
#--------------------------------------------------------------------------
# Install PHP dependencies and extensions
#--------------------------------------------------------------------------
#
RUN apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
    && apk add --no-cache \
        bash \
        freetype \
        libpng \
        libjpeg-turbo \
        freetype-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        libzip-dev \
        bzip2-dev \
        git \
    && rm -rf /tmp/pear \
    # Misic extensions
    && docker-php-ext-install \
        pdo_mysql \
        opcache \
        pcntl \
        bcmath \
        zip \
    # GD image extensions
    && docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NPROC} gd \
    # composer
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && composer global require "hirak/prestissimo" \
    # remove caches
    && apk del -f .build-deps


#
#--------------------------------------------------------------------------
# Redis extension
#--------------------------------------------------------------------------
#
ARG INSTALL_PHPREDIS=false
RUN if [ ${INSTALL_PHPREDIS} = true ]; then \
    apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    && pecl install -o -f redis \
    && docker-php-ext-enable redis \
    && apk del -f .build-deps \
;fi


#
#--------------------------------------------------------------------------
# xdebug
#--------------------------------------------------------------------------
#
ARG INSTALL_XDEBUG=false
ARG XDEBUG_FILE=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN if [ ${INSTALL_XDEBUG} = true ]; then \
    apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    && pecl install xdebug-2.7.1 \
    && docker-php-ext-enable xdebug \
    && apk del -f .build-deps \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > ${XDEBUG_FILE} \
    && echo "xdebug.remote_enable=1" >> ${XDEBUG_FILE} \
    && echo "xdebug.remote_autostart=on" >> ${XDEBUG_FILE} \
    && echo "xdebug.remote_host=172.17.0.1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9000" >> ${XDEBUG_FILE} \
    && echo "xdebug.remote_log=/tmp/xdebug.log" >> ${XDEBUG_FILE} \
;fi


###########################################################################
# PHP Memcached:
###########################################################################
ARG INSTALL_MEMCACHED=false


ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev
RUN if [ ${INSTALL_MEMCACHED} = true ]; then \
    apk add --no-cache --update libmemcached-libs zlib \
    && set -xe \
        && apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS \
        && apk add --no-cache --update --virtual .memcached-deps $MEMCACHED_DEPS \
        && pecl install memcached \
        && echo "extension=memcached.so" > /usr/local/etc/php/conf.d/20_memcached.ini \
        && rm -rf /usr/share/php7 \
        && rm -rf /tmp/* \
        && apk del .memcached-deps .phpize-deps \
;fi


#
#--------------------------------------------------------------------------
# php.ini
#--------------------------------------------------------------------------
#
ARG PHP_INI_FILE=/usr/local/etc/php/php.ini
ADD https://raw.githubusercontent.com/php/php-src/PHP-${PHP_VERSION}/php.ini-production ${PHP_INI_FILE}

#
#--------------------------------------------------------------------------
# opcache
#--------------------------------------------------------------------------
#
ARG OPCACHE_FILE=/usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
RUN echo "opcache.enable=On" >> ${OPCACHE_FILE} \
    && echo "opcache.memory_consumption=128" >> ${OPCACHE_FILE}

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#
RUN apk --no-cache add shadow && \
    usermod -u 1000 www-data \
    && apk del shadow


COPY ./start.sh /opt/start.sh

EXPOSE 9000

WORKDIR "/var/www"
CMD ["/bin/bash", "/opt/start.sh"]
