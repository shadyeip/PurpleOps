#!/bin/sh

if [ ! -f "/etc/nginx/ssl/privkey.pem" ] || [ ! -f "/etc/nginx/ssl/cert.pem" ]; then
    echo "Generating self-signed certificates"
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/privkey.pem -out /etc/nginx/ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=purpleops"
else
    echo "Nginx SSL certificates already exist"
fi

# Execute the CMD
exec "$@"
