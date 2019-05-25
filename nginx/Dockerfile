FROM nginx:1.16.0-alpine

LABEL maintainer="Panagiotis Koursaris <panakourweb@gmail.com>"

COPY nginx.conf /etc/nginx/

RUN apk update \
    && apk upgrade \
    && apk add --no-cache openssl \
    && apk add --no-cache bash

ARG PHP_UPSTREAM_CONTAINER=php-fpm
ARG PHP_UPSTREAM_PORT=9000

# Set upstream conf and remove the default conf
RUN echo "upstream php-upstream { server ${PHP_UPSTREAM_CONTAINER}:${PHP_UPSTREAM_PORT}; }" > /etc/nginx/conf.d/upstream.conf \
    && rm /etc/nginx/conf.d/default.conf


COPY ./start.sh /opt/start.sh

EXPOSE 80 443

CMD ["/bin/bash", "/opt/start.sh"]
