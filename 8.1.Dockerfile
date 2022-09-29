FROM php:8.1.11-fpm-alpine3.15

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV \
  MAXMIND_VERSION=1.4.2 \
  SWOOLE_VERSION=4.8.9 \
  SWOOLE_ASYNC_VERSION=4.5.5 \
  LD_PRELOAD=/usr/lib/preloadable_libiconv.so \
  PECL_EXTENSIONS_FUTURE="event hrtime imagick lua ssh2-1.2 xlswriter" \
  PECL_EXTENSIONS="apcu ast ds ev grpc igbinary lzf memcached mongodb msgpack oauth pcov psr redis rdkafka uuid xdebug xhprof yaf yaml" \
  PHP_EXTENSIONS="bcmath bz2 calendar exif gd gettext gmp imap intl ldap mysqli pcntl pdo_mysql pgsql pdo_pgsql \
    pspell shmop soap sockets sysvshm sysvmsg sysvsem tidy xsl zip"

# docker-php-ext-*
COPY docker-php-ext-disable.sh /usr/local/bin/docker-php-ext-disable

RUN \
# deps
  apk add -U --no-cache --virtual temp \
    # dev deps
    autoconf g++ file re2c make zlib-dev libtool aspell-dev pcre-dev libxml2-dev bzip2-dev libzip-dev \
      icu-dev gettext-dev imagemagick-dev openldap-dev libpng-dev gmp-dev yaml-dev postgresql-dev \
      libxml2-dev tidyhtml-dev libmemcached-dev libssh2-dev libevent-dev libev-dev librdkafka-dev lua-dev libxslt-dev \
      freetype-dev jpeg-dev libjpeg-turbo-dev oniguruma-dev \
    # prod deps
    && apk add --no-cache aspell gettext gnu-libiconv grpc icu imagemagick imap-dev libzip libbz2 librdkafka libxml2-utils libpq \
      libmemcached libssh2 libevent libev libxslt linux-headers lua openldap openldap-back-mdb tidyhtml yaml zlib \
#
# php extensions
  && docker-php-source extract \
    && pecl channel-update pecl.php.net \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --enable-gd \
    && docker-php-ext-install $PHP_EXTENSIONS > /dev/null \
    && pecl install $PECL_EXTENSIONS > /dev/null \
    && docker-php-ext-enable $(echo $PECL_EXTENSIONS | sed -E 's/\-[^ ]+//g') opcache \
    && cd /usr/src/php/ext/ \
    # swoole
    && curl -sSLo swoole.tar.gz https://github.com/swoole/swoole-src/archive/v$SWOOLE_VERSION.tar.gz \
      && tar xzf swoole.tar.gz && mv swoole-src-$SWOOLE_VERSION swoole \
    # && curl -sSLo swoole_async.tar.gz https://github.com/swoole/ext-async/archive/v$SWOOLE_ASYNC_VERSION.tar.gz \
    #  && tar xzf swoole_async.tar.gz && mv ext-async-$SWOOLE_ASYNC_VERSION swoole_async \
      && rm -f swoole.tar.gz swoole_async.tar.gz \
    && docker-php-ext-install -j "$(nproc)" swoole \
  && docker-php-source delete \
#
# composer
  && curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && curl -sSL https://getcomposer.org/installer | php -- --1 --install-dir=/usr/local/bin --filename=composer1 \
#
# cleanup
  && apk del temp \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

# ext
COPY ext.php /ext.php
RUN php -f /ext.php
