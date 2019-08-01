FROM balenalib/raspberry-pi-alpine:3.9

LABEL maintainer "FlorentinTh florentin.thullier1@uqac.ca"

ENV CERTBOT_VERSION 0.36

RUN set -x && apk --no-cache add certbot>${CERTBOT_VERSION}

VOLUME /var/lib/letsencrypt

EXPOSE 80 443

ENTRYPOINT [ "certbot" ]