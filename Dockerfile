FROM alpine:latest AS sourcecode
COPY . /tmp/mikhmon
FROM php:7.4-fpm-alpine3.16
RUN apk add --no-cache nginx \
    && mkdir -p /run/nginx /etc/nginx/http.d/

RUN echo 'server { \
    listen 80; \
    root /var/www/mikhmon; \
    index index.php index.html; \
    location / { \
        try_files $uri $uri/ /index.php?$query_string; \
    } \
    location ~ \.php$ { \
        include fastcgi_params; \
        fastcgi_pass 127.0.0.1:9000; \
        fastcgi_index index.php; \
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; \
    } \
    location ~ /\.ht { \
        deny all; \
    } \
}' > /etc/nginx/http.d/default.conf

WORKDIR /var/www/mikhmon
COPY --from=sourcecode /tmp/mikhmon ./

# Set permissions
RUN chown -R www-data:www-data /var/www/mikhmon

VOLUME ["/var/www/mikhmon"]

# Expose port 8020 for Nginx
EXPOSE 80

# Start both Nginx and PHP-FPM without using supervisord
CMD ["/bin/sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
