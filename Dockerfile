FROM php:8.0.6-fpm-alpine3.12

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV \
  MAXMIND_VERSION=1.4.2 \
  SWOOLE_VERSION=4.5.9 \
  SWOOLE_ASYNC_VERSION=4.5.5 \
  LD_PRELOAD=/usr/lib/preloadable_libiconv.so \
  PECL_EXTENSIONS_FUTURE="ev event hrtime imagick lua rdkafka ssh2-1.2 xlswriter yaf" \
  PECL_EXTENSIONS="apcu ast ds igbinary lzf memcached mongodb msgpack oauth pcov psr redis uuid xdebug xhprof yaml" \
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
      libxml2-dev tidyhtml-dev libmemcached-dev libssh2-dev libevent-dev libev-dev lua-dev libxslt-dev \
    # prod deps
    && apk add --no-cache aspell gettext gnu-libiconv icu imagemagick imap-dev libzip libbz2 libxml2-utils libpq \
      libmemcached libssh2 libevent libev libxslt lua openldap openldap-back-mdb tidyhtml yaml \
#
# php extensions
  && docker-php-source extract \
    && docker-php-ext-install $PHP_EXTENSIONS > /dev/null \
    && pecl install $PECL_EXTENSIONS > /dev/null \
    && docker-php-ext-enable $(echo $PECL_EXTENSIONS | sed -E 's/\-[^ ]+//g') opcache \
    && cd /usr/src/php/ext/ \
    # swoole
    && curl -sSLo swoole.tar.gz https://github.com/swoole/swoole-src/archive/v$SWOOLE_VERSION.tar.gz \
      && curl -sSLo swoole_async.tar.gz https://github.com/swoole/ext-async/archive/v$SWOOLE_ASYNC_VERSION.tar.gz \
      && tar xzf swoole.tar.gz && tar xzf swoole_async.tar.gz \
      && mv swoole-src-$SWOOLE_VERSION swoole && mv ext-async-$SWOOLE_ASYNC_VERSION swoole_async \
      && rm -f swoole.tar.gz swoole_async.tar.gz \
    && docker-php-ext-install -j "$(nproc)" swoole \
  && docker-php-source delete \
#
# composer
  && curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer2 \
  && curl -sSL https://getcomposer.org/installer | php -- --1 --install-dir=/usr/local/bin --filename=composer \
#
# cleanup
  && apk del temp \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

# ext
COPY ext.php /ext.php
RUN php -f /ext.php
