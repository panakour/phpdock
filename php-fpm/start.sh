#!/bin/bash

/usr/sbin/crond

# Display Version Details
if [[ "$EXPOSE_PHP" == "true" ]] ; then
 sed -i "s/expose_php = Off/expose_php = On/g" /usr/local/etc/php/php.ini
fi


# php.ini
if [ ! -z "$PHP_MAX_EXECUTION_TIME" ]; then
    sed -i "s/max_execution_time = 30/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/g" /usr/local/etc/php/php.ini
fi

if [ ! -z "$PHP_MEMORY_LIMIT" ]; then
    sed -i "s/memory_limit = 128M/memory_limit = ${PHP_MEMORY_LIMIT}M/g" /usr/local/etc/php/php.ini
fi

if [ ! -z "$PHP_POST_MAX_SIZE" ]; then
    sed -i "s/post_max_size = 8M/post_max_size = ${PHP_POST_MAX_SIZE}M/g" /usr/local/etc/php/php.ini
fi

if [ ! -z "$PHP_UPLOAD_MAX_FILESIZE" ]; then
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}M/g" /usr/local/etc/php/php.ini
fi


# opcache
if [ ! -z "$PHP_OPCACHE_MEMORY_CONSUMPTION" ]; then
    sed -i "s/opcache.memory_consumption=128/opcache.memory_consumption=${PHP_OPCACHE_MEMORY_CONSUMPTION}/g" /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
fi


php-fpm
