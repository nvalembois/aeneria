FROM docker.io/nginxinc/nginx-unprivileged:1.25.4-alpine3.18
ARG AENERIA_RELEASE=2.1.1

USER root

RUN set -e \
 && install -d -o root -g nginx -m 0750 /var/www \
 && wget -q -O - https://gitlab.com/aeneria/aeneria-app/-/archive/${AENERIA_RELEASE}/aeneria-app-${AENERIA_RELEASE}.tar.bz2 \
 | tar xjvf - --directory /var/www --strip-components=2 aeneria-app-${AENERIA_RELEASE}/app/public

ADD nginx.conf /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/

USER nginx

ENTRYPOINT [ "" ]
CMD [ "nginx" ]

WORKDIR /var/www
