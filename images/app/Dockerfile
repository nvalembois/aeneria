# FROM docker.io/library/php:cli-alpine3.19 AS build

# ADD preload.php /tmp/preload.php

# RUN set -e \
#  && curl -OL https://gitlab.com/aeneria/aeneria-app/-/archive/${AENERIA_VERSION}/aeneria-app-${AENERIA_VERSION}.tar.bz2 \
#  && tar xavf aeneria-app-${AENERIA_VERSION}.tar.bz2 --directory /var/www --strip-components=1 --exclude-vcs-ignores aeneria-app-${AENERIA_VERSION}/app/ \
#  && docker-php-ext-install -j$(nproc) opcache \
#  && mkdir /opcache \
#  && php /tmp/preload.php
ARG PHP_FPM_VERSION

FROM docker.io/library/php:${PHP_FPM_VERSION}
ARG AENERIA_VERSION

RUN apk add --update --no-cache --virtual .build-dependencies $PHPIZE_DEPS icu-dev curl-dev libzip-dev libxml2-dev libpng-dev libpq-dev openldap-dev postgresql-client \
 && apk add --update --no-cache icu-libs libcurl libzip libxml2 libpng libpq libldap \
 && pecl install apcu \
 && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
 && docker-php-ext-install -j$(nproc) pgsql pdo_pgsql zip xml intl gd curl bcmath opcache ldap \
 && docker-php-ext-enable apcu pdo_pg sql sodium ldap opcache \
 && pecl clear-cache \
 && apk del .build-dependencies

RUN set -e \
 && wget -q -O - https://gitlab.com/aeneria/aeneria-app/-/archive/${AENERIA_VERSION}/aeneria-app-${AENERIA_VERSION}.tar.bz2 \
  | tar xjvf - --directory /var/www --strip-components=2 aeneria-app-${AENERIA_VERSION}/app/ \
 && adduser -u 10000 --no-create-home --disabled-password --home / php \
 && chgrp -R php /var/www \
 && chmod -R o-rwx,g-w,g+rX /var/www

ADD zz-opcache.ini "$PHP_INI_DIR/conf.d/zz-opcache.ini"
ADD www.conf zz-docker.conf /usr/local/etc/php-fpm.d/

ENV FPM_LISTEN 9000
ENV FPM_MAX_CHILDREN 5
ENV FPM_START_SERVERS 1
ENV FPM_MIN_SPARE_SERVERS 1
ENV FPM_MAX_SPARE_SERVERS 3

USER php:php