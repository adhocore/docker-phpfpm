FROM php:7.2.14-fpm-alpine3.8

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

RUN \
  # Define
  PECL_EXTENSIONS="redis"; \
  PHP_EXTENSIONS="bcmath opcache pdo_mysql mysqli zip"; \
  # Dev deps
  apk add -U --virtual temp autoconf g++ file re2c make zlib-dev pcre-dev \
  # PHP extensions
  && docker-php-source extract \
    && pecl channel-update pecl.php.net \
    && pecl install $PECL_EXTENSIONS \
    && docker-php-ext-enable $PECL_EXTENSIONS \
    && docker-php-source delete \
    && docker-php-ext-install $PHP_EXTENSIONS \
  # Composer
  curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  # Cleanup
  && apk del temp \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* \
    && rm -rf /usr/share/doc/* /usr/share/man/* \
    && rm -rf /usr/src/php.tar.xz /usr/local/bin/docker-php-ext*

USER www-data

WORKDIR /var/www/html
