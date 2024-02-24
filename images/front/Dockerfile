ARG NODE_VERSION
ARG NGINX_VERSION
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

ARG NGINX_VERSION
FROM docker.io/nginxinc/nginx-unprivileged:${NGINX_VERSION} AS run

USER root

RUN set -e \
 && adduser -u 10001 --no-create-home --disabled-password --home /var/www/app aeneria \
 && mkdir -p /var/www/app \
 && chown -R aeneria:nginx /var/www \
 && chmod -R o-rwx,g-w,g+rX /var/www

COPY --from=build --chown=aeneria:nginx /var/www/app/public /var/www/app/public

ADD nginx.conf /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/

USER nginx

ENTRYPOINT [ "" ]
CMD [ "nginx" ]

WORKDIR /var/www
