ARG NGINX_VERSION
FROM docker.io/nginxinc/nginx-unprivileged:${NGINX_VERSION}

USER root

ARG AENERIA_VERSION
RUN set -e \
 && install -d -o root -g nginx -m 0750 /var/www \
 && wget -q -O - https://gitlab.com/aeneria/aeneria-app/-/archive/${AENERIA_VERSION}/aeneria-app-${AENERIA_VERSION}.tar.bz2 \
 | tar xjvf - --directory /var/www --strip-components=2 aeneria-app-${AENERIA_VERSION}/app/public

ADD nginx.conf /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/

USER nginx

ENTRYPOINT [ "" ]
CMD [ "nginx" ]

WORKDIR /var/www
