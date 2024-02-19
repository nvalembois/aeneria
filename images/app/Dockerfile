FROM docker.io/library/php:cli-alpine3.19 AS build
ARG AENERIA_RELEASE=2.1.1

ADD opcache.ini "$PHP_INI_DIR/conf.d/opcache.ini"
ADD preload.php /tmp/preload.php

RUN set -e \
 && curl -OL https://gitlab.com/aeneria/aeneria-app/-/archive/${AENERIA_RELEASE}/aeneria-app-${AENERIA_RELEASE}.tar.bz2 \
 && tar xavf aeneria-app-${AENERIA_RELEASE}.tar.bz2 --directory /var/www --strip-components=1 --exclude-vcs-ignores aeneria-app-${AENERIA_RELEASE}/app/ \
 && ls -l /var/www/ \
 && docker-php-ext-install -j$(nproc) opcache \
 && mkdir /opcache \
 && php /tmp/preload.php

FROM docker.io/library/php:fpm-alpine3.19

RUN apk add --update --no-cache --virtual .build-dependencies $PHPIZE_DEPS icu-dev curl-dev libzip-dev libxml2-dev libpng-dev libpq-dev openldap-dev postgresql-client \
 && apk add --update --no-cache icu-libs libcurl libzip libxml2 libpng libpq libldap \
 && pecl install apcu \
 && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
 && docker-php-ext-install -j$(nproc) pgsql pdo_pgsql zip xml intl gd curl bcmath opcache ldap \
 && docker-php-ext-enable apcu pdo_pgsql sodium ldap opcache \
 && pecl clear-cache \
 && apk del .build-dependencies

ADD opcache.ini "$PHP_INI_DIR/conf.d/opcache.ini"

RUN adduser -u 10000 --no-create-home --disabled-password --home / php

COPY --from=build --chown=www-data:www-data /var/www/app/ /var/www/
COPY --from=build --chown=php:php  /opcache /opcache

USER php:php