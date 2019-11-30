FROM php:7.4.0-fpm-alpine3.10

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV XHPROF_VERSION=5.0.1
ENV PECL_EXTENSIONS="redis yaml imagick xdebug"
ENV PHP_EXTENSIONS="bcmath bz2 calendar exif gd gettext gmp intl ldap mysqli opcache pdo_mysql soap zip"

RUN \
  # deps
  apk add -U --virtual temp \
    autoconf g++ file re2c make zlib-dev libtool pcre-dev libxml2-dev bzip2-dev libzip-dev \
      icu-dev gettext-dev imagemagick-dev openldap-dev libpng-dev gmp-dev yaml-dev \
    && apk add icu gettext imagemagick libzip libbz2 libxml2-utils openldap-back-mdb openldap yaml

RUN \
  # php extensions
  docker-php-source extract \
    && pecl channel-update pecl.php.net \
    && pecl install $PECL_EXTENSIONS \
    && docker-php-ext-enable ${PECL_EXTENSIONS//[-\.0-9]/} \
    && docker-php-ext-install $PHP_EXTENSIONS

RUN \
  # tideways_xhprof
  curl -sSLo /tmp/xhprof.tar.gz https://github.com/tideways/php-xhprof-extension/archive/v$XHPROF_VERSION.tar.gz \
    && tar xzf /tmp/xhprof.tar.gz && cd php-xhprof-extension-$XHPROF_VERSION \
    && phpize && ./configure \
    && make && make install \
    && docker-php-ext-enable tideways_xhprof \
    && cd .. && rm -rf php-xhprof-extension-$XHPROF_VERSION /tmp/xhprof.tar.gz \
  && docker-php-source delete

RUN \
  # composer
  curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN \
  # cleanup
  apk del temp \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*
