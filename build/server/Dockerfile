FROM ubuntu:18.04

LABEL maintainer "FlorentinTh florentin.thullier1@uqac.ca"

ARG TZ
ARG DOMAIN

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:certbot/certbot
RUN apt-get update
RUN apt-get install -y certbot python-certbot-nginx
RUN apt-get install -y openssl nginx 

RUN openssl dhparam -out /etc/nginx/dhparam.pem 2048

RUN mkdir -p /var/www/_letsencrypt
RUN chown www-data /var/www/_letsencrypt

COPY ./nginx/$DOMAIN /etc/nginx/$DOMAIN
COPY ./nginx/sites-available/ /etc/nginx/sites-available/
COPY ./nginx/nginx.conf /etc/nginx
COPY ./letsencrypt /etc/letsencrypt
COPY ./www/html /var/www/$DOMAIN

RUN ln -s /etc/nginx/sites-available/$DOMAIN.conf /etc/nginx/sites-enabled/

EXPOSE 80 443

ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]