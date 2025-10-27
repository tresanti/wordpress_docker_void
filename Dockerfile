# Usa l'immagine di PHP con FPM e Nginx
FROM php:8.1-fpm-alpine

# Installazione delle dipendenze di sistema
RUN apk update && apk add --no-cache shadow\
    nginx \
    bash \
    vim \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    zlib-dev \
    libxml2-dev \
    libzip-dev

RUN docker-php-ext-configure gd --with-jpeg --with-webp

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-install -j$(nproc) \
    gd \
    pdo \
    pdo_mysql \
    mysqli \
    dom \
    xml \
    ctype \
    zip \
    fileinfo

# Copia la configurazione principale di Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copia il file .user.ini per la configurazione di PHP
COPY .user.ini /usr/local/etc/php/conf.d/

# Copia i file di WordPress
COPY ./wordpress_data /var/www/html

# Copia lo script di avvio
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
