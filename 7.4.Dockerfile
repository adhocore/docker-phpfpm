FROM php:7.4.33-fpm-alpine3.16

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV \
  XHPROF_VERSION=5.0.1\
  ZEPHIR_VERSION=1.3.3 \
  PHALCON_VERSION=4.0.0 \
  SWOOLE_VERSION=4.6.7 \
  SWOOLE_ASYNC_VERSION=4.5.5 \
  LD_PRELOAD=/usr/lib/preloadable_libiconv.so \
  PECL_EXTENSIONS="apcu ast ds ev hrtime igbinary imagick lzf lua mongodb memcached msgpack oauth pcov psr rdkafka redis \
    simdjson ssh2-1.2 uuid xdebug-3.1.6 xlswriter yaf yaml" \
  PHP_EXTENSIONS="bcmath bz2 calendar exif gd gettext gmp imap intl ldap mysqli pcntl pdo_mysql pgsql pdo_pgsql \
    soap sockets sysvshm sysvmsg sysvsem tidy zip"

# docker-*
COPY docker-* /usr/local/bin/

# copy from existing
COPY --from=adhocore/phpfpm:7.4 /usr/local/lib/php/extensions/no-debug-non-zts-20190902/*.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/
COPY --from=adhocore/phpfpm:7.4 /usr/local/etc/php/conf.d/*.ini /usr/local/etc/php/conf.d/

# ext
COPY ext.php /ext.php

RUN \
# deps
  apk add -U --no-cache --virtual temp \
    # dev deps
    autoconf g++ file re2c make zlib-dev libtool pcre-dev libxml2-dev bzip2-dev libzip-dev \
      icu-dev gettext-dev imagemagick-dev openldap-dev libpng-dev gmp-dev yaml-dev postgresql-dev \
      libxml2-dev tidyhtml-dev libmemcached-dev libssh2-dev libevent-dev libev-dev librdkafka-dev lua-dev \
      freetype-dev jpeg-dev libjpeg-turbo-dev oniguruma-dev \
    # prod deps
    && apk add --no-cache icu gettext gnu-libiconv grpc imagemagick libjpeg libzip libbz2 libxml2-utils openldap-back-mdb openldap yaml \
      libpq tidyhtml imap-dev libmemcached libssh2 libevent libev librdkafka linux-headers lua zlib \
#
# php extensions
  && docker-php-source extract \
    && cd /usr/local/lib/php/extensions/no-debug-non-zts-20190902 && rm -f intl.so mongodb.so && cd - \
    && cd /usr/local/etc/php/conf.d && rm -f *-intl.ini *-mongodb.ini && cd - \
    && pecl channel-update pecl.php.net \
    && docker-pecl-ext-install $PECL_EXTENSIONS \
    && { docker-php-ext-enable $(echo $PECL_EXTENSIONS | sed -E 's/\-[^ ]+//g') opcache > /dev/null || true; } \
    # zephir_parser
    # && { php -m | grep zephir_parser || (curl -sSLo zephir_parser.tar.gz https://github.com/phalcon/php-zephir-parser/archive/v$ZEPHIR_VERSION.tar.gz \
    #   && tar xzf zephir_parser.tar.gz \
    #   && rm -f zephir_parser.tar.gz \
    #   && mv php-zephir-parser-$ZEPHIR_VERSION zephir_parser); } \
    && { php -m | grep gd || docker-php-ext-configure gd --with-freetype --with-jpeg --enable-gd; } \
    && docker-php-ext-install-if $PHP_EXTENSIONS \
    && cd /usr/local/etc/php/conf.d/ \
      && { mv docker-php-ext-event.ini docker-php-ext-zevent.ini || true; } \
    && { pecl clear-cache || true; } \
  && { php -m | grep xdebug && docker-php-ext-disable xdebug || true; } \
    && docker-php-source delete \
#
# tideways_xhprof
  && { php -m | grep tideways_xhprof || (curl -sSLo /tmp/xhprof.tar.gz https://github.com/tideways/php-xhprof-extension/archive/v$XHPROF_VERSION.tar.gz \
    && cd /tmp/ && tar xzf xhprof.tar.gz && cd php-xhprof-extension-$XHPROF_VERSION \
    && phpize && ./configure \
    && make -j "$(nproc)" && make install \
    && docker-php-ext-enable tideways_xhprof); } \
#
# composer
  && curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer2 \
  && curl -sSL https://getcomposer.org/installer | php -- --1 --install-dir=/usr/local/bin --filename=composer \
#  && composer global require hirak/prestissimo \
#
# cleanup
  && apk del temp \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/* \
    && php -f /ext.php
