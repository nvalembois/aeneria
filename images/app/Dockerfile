ARG NODE_VERSION
ARG PHP_FPM_VERSION
FROM docker.io/library/node:${NODE_VERSION} AS build

ARG AENERIA_VERSION
RUN set -e \
 && apk add --update --no-cache --virtual .build-dependencies jq python3 gcc g++ make \
 && mkdir -p /var/www \
 && wget -q -O - https://gitlab.com/aeneria/aeneria-app/-/archive/${AENERIA_VERSION}/aeneria-app-${AENERIA_VERSION}.tar.bz2 \
  | tar xjvf - --directory /var/www --strip-components=1 \
 && cd /var/www/app-front \
 && yarn install \
 && yarn build \
 && apk del .build-dependencies

ARG PHP_FPM_VERSION
FROM docker.io/library/php:${PHP_FPM_VERSION} AS run

RUN set -e \
 && apk add --update --no-cache --virtual .build-dependencies $PHPIZE_DEPS icu-dev curl-dev libzip-dev libxml2-dev libpng-dev libpq-dev openldap-dev postgresql-client \
 && apk add --update --no-cache icu-libs libcurl libzip libxml2 libpng libpq libldap \
 && pecl install apcu \
 && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
 && docker-php-ext-install -j$(nproc) pgsql pdo_pgsql zip xml intl gd curl bcmath opcache ldap \
 && docker-php-ext-enable apcu pdo_pgsql sodium ldap opcache \
 && pecl clear-cache \
 && apk del .build-dependencies

RUN set -e \
 && cp ${PHP_INI_DIR}/php.ini-production ${PHP_INI_DIR}/php.ini

ADD zz-opcache.ini zz-logging.ini ${PHP_INI_DIR}/conf.d/
ADD www.conf zz-docker.conf /usr/local/etc/php-fpm.d/

ENV FPM_LOGLEVEL notice
ENV PHP_DISPLAY_ERRORS 0
ENV PHP_LOG_ERRORS 1
ENV FPM_MAX_CHILDREN 5
ENV FPM_START_SERVERS 1
ENV FPM_MIN_SPARE_SERVERS 1
ENV FPM_MAX_SPARE_SERVERS 3

RUN set -e \
 && adduser -u 10000 --no-create-home --disabled-password --home / php \
 && adduser -u 10001 --no-create-home --disabled-password --home /var/www/app aeneria \
 && chown -R aeneria:php /var/www \
 && chmod -R o-rwx,g-w,g+rX /var/www

RUN set -e \
 && EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')" \
 && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")" \
 && [ "$EXPECTED_CHECKSUM" == "$ACTUAL_CHECKSUM" ] \
 && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

USER aeneria

ENV APP_ENV prod
ENV AENERIA_USER_MAX_PLACES -1
ENV AENERIA_USER_CAN_SHARE_PLACE 1
ENV AENERIA_USER_CAN_FETCH 1
ENV AENERIA_USER_CAN_EXPORT 1
ENV AENERIA_USER_CAN_IMPORT 1
ENV AENERIA_PLACE_CAN_BE_PUBLIC 1
ENV AENERIA_DEMO_MODE 0
ENV AENERIA_WELCOME_MESSAGE '<h1>Bienvenue sur æneria</h1>'
ENV AENERIA_PROXY_URL https://proxy.aeneria.com
ENV AENERIA_PROXY_FOR_ENEDIS ''
ENV AENERIA_PROXY_FOR_GRDF ''
ENV ENEDIS_CLIENT_ID ''
ENV ENEDIS_CLIENT_SECRET ''
ENV ENEDIS_REDIRECT_URI ''
ENV ENEDIS_ENDPOINT_AUTH https://mon-compte-particulier.enedis.fr
ENV ENEDIS_ENDPOINT_TOKEN https://ext.prod.api.enedis.fr
ENV ENEDIS_ENDPOINT_DATA https://ext.prod.api.enedis.fr
ENV GRDF_CLIENT_ID ''
ENV GRDF_CLIENT_SECRET ''
ENV GRDF_REDIRECT_URI ''
ENV GRDF_ENDPOINT_AUTH https://sofit-sso-oidc.grdf.fr
ENV GRDF_ENDPOINT_DATA https://api.grdf.fr

COPY --from=build --chown=aeneria:php /var/www/app /var/www/app
ADD monolog.yaml /var/www/app/config/packages/prod/
RUN set -e \
 && cd /var/www/app \
 && composer install --no-cache --no-interaction --no-dev --optimize-autoloader \
 && APP_SECRET='' php bin/console cache:clear \
 && APP_SECRET='' php bin/console cache:warmup \
 && rm -R tests phpstan.dist.neon phpunit.xml.dist symfony.lock

WORKDIR /var/www/app
USER php:php