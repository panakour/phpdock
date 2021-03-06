ARG PHP_VERSION=8.0

FROM php:${PHP_VERSION}-fpm-alpine

LABEL maintainer="Panagiotis Koursaris <panakourweb@gmail.com>"


###########################################################################
# Install PHP dependencies and extensions:
###########################################################################
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
        icu-dev \
    # Misic extensions
    && docker-php-ext-install \
        pdo_mysql \
        opcache \
        pcntl \
        bcmath \
        zip \
        intl \
    # GD image extensions
    && docker-php-ext-configure gd \
        --enable-gd \
        --with-freetype=/usr/include/ \
        --with-jpeg=/usr/include/ \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NPROC} gd \
    # composer
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    # remove caches
    && apk del -f .build-deps


###########################################################################
# redis:
###########################################################################
ARG INSTALL_PHPREDIS=false
RUN if [ ${INSTALL_PHPREDIS} = true ]; then \
    apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    && pecl install -o -f redis \
    && docker-php-ext-enable redis \
    && apk del -f .build-deps \
;fi


###########################################################################
# xdebug:
###########################################################################
ARG INSTALL_XDEBUG=false
ARG XDEBUG_FILE=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN if [ ${INSTALL_XDEBUG} = true ]; then \
    apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    && pecl install xdebug-3.0.2 \
    && docker-php-ext-enable xdebug \
    && apk del -f .build-deps \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > ${XDEBUG_FILE} \
    && echo "xdebug.mode=debug" >> ${XDEBUG_FILE} \
    && echo "xdebug.start_with_request=yes" >> ${XDEBUG_FILE} \
    && echo "xdebug.client_host=172.17.0.1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port=9000" >> ${XDEBUG_FILE} \
    && echo "xdebug.log=/tmp/xdebug.log" >> ${XDEBUG_FILE} \
    && touch "/tmp/xdebug.log" \
    && chmod 666 "/tmp/xdebug.log" \
;fi


###########################################################################
# ImageMagick: not supported yet for php 8
###########################################################################
#ARG INSTALL_IMAGEMAGICK=false
#RUN if [ ${INSTALL_IMAGEMAGICK} = true ]; then \
#    apk add --no-cache --virtual .build-deps imagemagick-dev \
#    $PHPIZE_DEPS \
#    && apk add --no-cache --virtual .imagick-runtime-deps imagemagick \
#    && pecl install imagick \
#    && docker-php-ext-enable imagick \
#    && apk del -f .build-deps \
#;fi


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


###########################################################################
# php.ini:
###########################################################################
ARG PHP_INI_FILE=/usr/local/etc/php/php.ini
ADD https://raw.githubusercontent.com/php/php-src/PHP-${PHP_VERSION}/php.ini-production ${PHP_INI_FILE}


###########################################################################
# opcache:
###########################################################################
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

RUN rm -rf /tmp/pear

COPY crontab /etc/crontabs/root

COPY start.sh /opt/start.sh

EXPOSE 9000

WORKDIR "/var/www"
CMD ["/bin/bash", "/opt/start.sh"]
