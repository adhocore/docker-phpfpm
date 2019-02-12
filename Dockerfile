FROM php:7.2.14-fpm-alpine3.8

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

RUN \
  # Define
  PECL_EXTENSIONS="redis"; \
  PHP_EXTENSIONS="zip mysqli pdo_mysql opcache bcmath gd gmp intl ldap exif soap bz2 calendar"; \
  # Dev deps
  apk add -U --virtual temp autoconf g++ file re2c make zlib-dev libtool pcre-dev openldap-dev libxml2-dev bzip2-dev \
  # Deps
  && apk add libpng-dev gmp-dev icu-dev libzip-dev \
  # PHP extensions
  && docker-php-source extract \
    && pecl channel-update pecl.php.net \
    && pecl install $PECL_EXTENSIONS \
    && docker-php-ext-enable $PECL_EXTENSIONS \
    && docker-php-ext-install $PHP_EXTENSIONS \
    && docker-php-source delete \
  # Composer
  && curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  # Cleanup
  && apk del temp \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* \
    && rm -rf /usr/share/doc/* /usr/share/man/* \
    && rm -rf /usr/src/php.tar.xz /usr/local/bin/docker-php-ext*

USER www-data

WORKDIR /var/www/html
