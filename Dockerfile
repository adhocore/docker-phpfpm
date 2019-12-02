FROM php:7.4.0-fpm-alpine3.10

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV XHPROF_VERSION=5.0.1
ENV PHALCON_VERSION=4.0.0-rc.3
ENV PECL_EXTENSIONS="imagick psr redis xdebug yaml"
ENV PHP_EXTENSIONS="bcmath bz2 calendar exif gd gettext gmp intl ldap mysqli pdo_mysql soap zip"

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
    && docker-php-ext-enable ${PECL_EXTENSIONS//[-\.0-9]/} opcache \
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
  # phalcon
  curl -sSLo /tmp/phalcon.tar.gz https://codeload.github.com/phalcon/cphalcon/tar.gz/v$PHALCON_VERSION \
    && cd /tmp/ && tar xvzf phalcon.tar.gz \
    && cd cphalcon-$PHALCON_VERSION/build && sh install \
    && docker-php-ext-enable phalcon --ini-name docker-php-ext-phalcon.ini

RUN \
  # composer
  curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN \
  # cleanup
  apk del temp \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*
