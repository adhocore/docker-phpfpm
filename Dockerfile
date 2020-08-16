FROM php:8.0.0beta1-fpm-alpine3.12

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV \
  XHPROF_VERSION=5.0.1 \
  ZEPHIR_VERSION=1.3.3 \
  PHALCON_VERSION=4.0.6 \
  SWOOLE_VERSION=4.5.2 \
  MAXMIND_VERSION=1.4.2 \
  PECL_EXTENSIONS_FUTURE="ds ev event hrtime imagick lua mongodb msgpack oauth redis ssh2-1.2 xdebug xlswriter yaf yaml" \
  PECL_EXTENSIONS="apcu ast igbinary lzf memcached pcov psr uuid" \
  PHP_EXTENSIONS="bcmath bz2 calendar exif gd gettext gmp imap intl ldap mysqli pcntl pdo_mysql pgsql pdo_pgsql \
    pspell shmop soap sockets sysvshm sysvmsg sysvsem tidy xsl zip"

# docker-php-ext-disable
COPY docker-php-ext-disable.sh /usr/local/bin/docker-php-ext-disable
COPY docker-pickle-ext-install.sh /usr/local/bin/docker-pickle-ext-install

RUN \
# deps
  apk add -U --no-cache --virtual temp \
    # dev deps
    autoconf g++ file re2c make zlib-dev libtool aspell-dev pcre-dev libxml2-dev bzip2-dev libzip-dev \
      icu-dev gettext-dev imagemagick-dev openldap-dev libpng-dev gmp-dev yaml-dev postgresql-dev \
      libxml2-dev tidyhtml-dev libmemcached-dev libssh2-dev libevent-dev libev-dev lua-dev libxslt-dev \
    # prod deps
    && apk add --no-cache aspell gettext icu imagemagick imap-dev libzip libbz2 libxml2-utils libpq \
      libmemcached libssh2 libevent libev libxslt lua openldap openldap-back-mdb tidyhtml yaml \
#
# php extensions
  && docker-php-source extract \
    && docker-php-ext-install $PHP_EXTENSIONS \
    && docker-pickle-ext-install $PECL_EXTENSIONS \
    && docker-php-ext-enable $(echo $PECL_EXTENSIONS | sed -E 's/\-[^ ]+//g') opcache \
    #&& cd /usr/src/php/ext/ \
    # swoole
    #&& curl -sSLo swoole.tar.gz https://github.com/swoole/swoole-src/archive/v$SWOOLE_VERSION.tar.gz \
    #  && curl -sSLo swoole_async.tar.gz https://github.com/swoole/ext-async/archive/v4.4.16.tar.gz \
    #  && tar xzf swoole.tar.gz && tar xzf swoole_async.tar.gz \
    #  && mv swoole-src-$SWOOLE_VERSION swoole && mv ext-async-4.4.16 swoole_async \
    #  && rm -f swoole.tar.gz swoole_async.tar.gz \
    # zephir_parser
    #&& curl -sSLo zephir_parser.tar.gz https://github.com/phalcon/php-zephir-parser/archive/v$ZEPHIR_VERSION.tar.gz \
    #  && tar xzf zephir_parser.tar.gz \
    #  && rm -f zephir_parser.tar.gz \
    #  && mv php-zephir-parser-$ZEPHIR_VERSION zephir_parser \
    #&& docker-php-ext-install -j "$(nproc)" swoole swoole_async zephir_parser \
    #&& cd /usr/local/etc/php/conf.d/ \
    #  && mv docker-php-ext-event.ini docker-php-ext-zevent.ini \
  && docker-php-source delete \
#
# tideways_xhprof
  #&& curl -sSLo /tmp/xhprof.tar.gz https://github.com/tideways/php-xhprof-extension/archive/v$XHPROF_VERSION.tar.gz \
  #  && cd /tmp/ && tar xzf xhprof.tar.gz && cd php-xhprof-extension-$XHPROF_VERSION \
  #  && phpize && ./configure \
  #  && make -j "$(nproc)" && make install \
  #  && docker-php-ext-enable tideways_xhprof \
#
# phalcon
  #&& curl -sSLo /tmp/phalcon.tar.gz https://codeload.github.com/phalcon/cphalcon/tar.gz/v$PHALCON_VERSION \
  #  && cd /tmp/ && tar xzf phalcon.tar.gz \
  #  && cd cphalcon-$PHALCON_VERSION/build && sh install \
  #  && docker-php-ext-enable phalcon --ini-name docker-php-ext-phalcon.ini \
#
# composer
  && curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && composer global require hirak/prestissimo \
#
# cleanup
  && apk del temp \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

# ext
COPY ext.php /ext.php
RUN php -f /ext.php
