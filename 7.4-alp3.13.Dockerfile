FROM php:7.4.21-fpm-alpine3.13

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV \
  XHPROF_VERSION=5.0.1\
  ZEPHIR_VERSION=1.3.3 \
  PHALCON_VERSION=4.0.0 \
  SWOOLE_VERSION=4.6.7 \
  SWOOLE_ASYNC_VERSION=4.5.5 \
  LD_PRELOAD=/usr/lib/preloadable_libiconv.so \
  PECL_EXTENSIONS="apcu ast ds ev grpc hrtime igbinary imagick lzf lua mongodb msgpack oauth pcov psr rdkafka redis \
    ssh2-1.2 uuid xdebug xlswriter yaf yaml" \
  PECL_BUNDLE="memcached event" \
  PHP_EXTENSIONS="bcmath bz2 calendar exif gd gettext gmp imap intl ldap mysqli pcntl pdo_mysql pgsql pdo_pgsql \
    soap sockets swoole sysvshm sysvmsg sysvsem tidy zip zephir_parser"

RUN \
# deps
  apk add -U --no-cache --virtual temp \
    # dev deps
    autoconf g++ file re2c make zlib-dev libtool pcre-dev libxml2-dev bzip2-dev libzip-dev \
      icu-dev gettext-dev imagemagick-dev openldap-dev libpng-dev gmp-dev yaml-dev postgresql-dev \
      libxml2-dev tidyhtml-dev libmemcached-dev libssh2-dev libevent-dev libev-dev librdkafka-dev lua-dev \
      freetype-dev jpeg-dev libjpeg-turbo-dev oniguruma-dev \
    # prod deps
    && apk add --no-cache icu gettext gnu-libiconv grpc imagemagick libzip libbz2 libxml2-utils openldap-back-mdb openldap yaml \
      libpq tidyhtml imap-dev libmemcached libssh2 libevent libev librdkafka linux-headers lua zlib \
#
# php extensions
  && docker-php-source extract \
    && pecl channel-update pecl.php.net \
    && pecl install $PECL_EXTENSIONS > /dev/null \
    && cd /usr/src/php/ext/ \
    && for BUNDLE_EXT in $PECL_BUNDLE; do pecl bundle $BUNDLE_EXT; done \
    && docker-php-ext-enable $(echo $PECL_EXTENSIONS | sed -E 's/\-[^ ]+//g') opcache \
    # swoole
    && curl -sSLo swoole.tar.gz https://github.com/swoole/swoole-src/archive/v$SWOOLE_VERSION.tar.gz \
      && curl -sSLo swoole_async.tar.gz https://github.com/swoole/ext-async/archive/v$SWOOLE_ASYNC_VERSION.tar.gz \
      && tar xzf swoole.tar.gz && tar xzf swoole_async.tar.gz \
      && mv swoole-src-$SWOOLE_VERSION swoole && mv ext-async-$SWOOLE_ASYNC_VERSION swoole_async \
      && rm -f swoole.tar.gz swoole_async.tar.gz \
    # zephir_parser
    && curl -sSLo zephir_parser.tar.gz https://github.com/phalcon/php-zephir-parser/archive/v$ZEPHIR_VERSION.tar.gz \
      && tar xzf zephir_parser.tar.gz \
      && rm -f zephir_parser.tar.gz \
      && mv php-zephir-parser-$ZEPHIR_VERSION zephir_parser \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --enable-gd \
    && docker-php-ext-install -j "$(nproc)" $PHP_EXTENSIONS $PECL_BUNDLE  > /dev/null \
    && cd /usr/local/etc/php/conf.d/ \
      && mv docker-php-ext-event.ini docker-php-ext-zevent.ini \
    && pecl clear-cache \
  && docker-php-source delete \
#
# tideways_xhprof
  && curl -sSLo /tmp/xhprof.tar.gz https://github.com/tideways/php-xhprof-extension/archive/v$XHPROF_VERSION.tar.gz \
    && cd /tmp/ && tar xzf xhprof.tar.gz && cd php-xhprof-extension-$XHPROF_VERSION \
    && phpize && ./configure \
    && make -j "$(nproc)" && make install \
    && docker-php-ext-enable tideways_xhprof \
#
# phalcon
  && curl -sSLo /tmp/phalcon.tar.gz https://codeload.github.com/phalcon/cphalcon/tar.gz/v$PHALCON_VERSION \
    && cd /tmp/ && tar xzf phalcon.tar.gz \
    && cd cphalcon-$PHALCON_VERSION/build && sh install \
    && docker-php-ext-enable phalcon --ini-name docker-php-ext-phalcon.ini \
#
# composer
  && curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer2 \
  && curl -sSL https://getcomposer.org/installer | php -- --1 --install-dir=/usr/local/bin --filename=composer \
#  && composer global require hirak/prestissimo \
#
# cleanup
  && apk del temp \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

# docker-php-ext-disable
COPY docker-php-ext-disable.sh /usr/local/bin/docker-php-ext-disable

# ext
COPY ext.php /ext.php
RUN php -f /ext.php
