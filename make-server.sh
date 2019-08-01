#!/bin/bash

DOMAIN="your_domain.example"
EMAIL="your.email@example.com"

ROOT=$(pwd)

function build_certbot_image() {
    echo "--------"
    echo "-- building certbot image..."
    echo "-------"
    cd "${ROOT}"/docker/certbot
    docker build --rm -f "Dockerfile" -t certbot:latest .
}

function init_generate_certs() {
    QUESTION="
    1- Generate test certificates (not safe for production)
    2- Generate real certificates (production ready)
    Choice [ENTER]: "

    while
        read -p "${QUESTION}" choice do
    do
        case "$choice" in
            1 )     generate_test_certs
                    break;;
            2 )     generate_prod_certs
                    break;;
            * ) echo "invalid";;
        esac
    done

    docker rm -f certbot

    DATE=$(date '+%Y-%m-%d')
    tar -czvf "${ROOT}"-certs-backup.tar.gz "${ROOT}"/letsencrypt
}

function print_certs_msg(){
    echo "--------"
    echo "-- generating certs..."
    echo "-------"   
}

function generate_test_certs(){
    print_certs_msg
    docker run --name certbot -v "${ROOT}"/letsencrypt:/etc/letsencrypt -p 80:80 -p 443:443 --entrypoint='' certbot:latest sh -c 'certbot certonly --test-cert --standalone --no-eff-email -d '"${DOMAIN}"' -d www.'"${DOMAIN}"' --email '"${EMAIL}"' --text --agree-tos --rsa-key-size 2048 --renew-by-default --preferred-challenges http-01'
}

function generate_prod_certs(){
    print_certs_msg
    docker run --name certbot -v "${ROOT}"/letsencrypt:/etc/letsencrypt -p 80:80 -p 443:443 --entrypoint='' certbot:latest sh -c 'certbot certonly --standalone --no-eff-email -d '"${DOMAIN}"' -d www.'"${DOMAIN}"' --email '"${EMAIL}"' --text --agree-tos --server https://acme-v01.api.letsencrypt.org/directory --rsa-key-size 2048 --renew-by-default --preferred-challenges http-01'
}

function deploy_app(){
    echo "--------"
    echo "-- deploying app..."
    echo "-------"
    cd "${ROOT}"
    sudo chown -R "${USER}":"${USER}" ./letsencrypt/
    docker-compose -f "docker-compose.yml" up -d --build
}

main() {
    MENU="
    1- Generate SSL certificates (only)
    2- Deploy app (only)
    3- Generate SSL certificates + deploy app
    Choice [ENTER]: "

    while
        read -p "${MENU}" choice do
    do
        case "$choice" in
            1 )     build_certbot_image
                    generate_certs
                    break;;
            2 )     deploy_app
                    break;;
            3 )     build_certbot_image
                    generate_certs
                    deploy_app
                    update
                    break;;
            * ) echo "invalid";;
        esac
    done
}

main "$@"