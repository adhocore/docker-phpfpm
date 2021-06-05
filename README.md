## docker-phpfpm

![Docker Build](https://img.shields.io/docker/cloud/build/adhocore/phpfpm?style=flat-square)
[![Donate](https://img.shields.io/badge/donate-paypal-blue.svg?style=flat-square)](https://www.paypal.me/ji10/50usd)
[![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=Production+ready+PHP7+and+PHP8+docker+images+with+plenty+extensions&url=https://github.com/adhocore/docker-phpfpm&hashtags=docker,dockerimage,php7,php8,phpext)


Docker PHP FPM with lean alpine base. The download size is just about ~150MB.

It contains PHP8.0.7 with plenty of common and useful extensions.

You can also continue using [`adhocore/phpfpm:7.4`](./7.4.Dockerfile) for PHP7.4.20.

If you are looking for a complete local development stack then check
[`adhocore/lemp`](https://github.com/adhocore/docker-lemp).

It comes prepackaged with `composer` - both v1 and v2.
Use `composer2` command for v2 and `composer` for v1.

## Usage
To pull latest image:

```sh
docker pull adhocore/phpfpm:8.0

# or for alpine 3.13
docker pull adhocore/phpfpm:8.0-alp3.13

# or for php 7.4
docker pull adhocore/phpfpm:7.4

# or for php 7.4 on alpine 3.13
docker pull adhocore/phpfpm:7.4-alp3.13

```

To use in docker-compose
```yaml
# ./docker-compose.yml
version: '3'

services:
  phpfpm:
    image: adhocore/phpfpm:8.0
    container_name: phpfpm
    volumes:
      - ./path/to/your/app:/var/www/html
      # Here you can also volume php ini settings
      # - /path/to/zz-overrides:/usr/local/etc/php/conf.d/zz-overrides.ini
    ports:
      - 9000:9000
    environment:
      # ...
```

### Extensions

#### PHP8.0

The following PHP extensions are installed in `adhocore/phpfpm:8.0`:

```
Total: 78
- apcu              - ast               - bcmath            - bz2
- calendar          - core              - ctype             - curl
- date              - dom               - ds                - exif
- fileinfo          - filter            - ftp               - gd
- gettext           - gmp               - grpc              - hash
- iconv             - igbinary          - imap              - intl
- json              - ldap              - libxml            - lzf
- mbstring          - memcached         - mongodb           - msgpack
- mysqli            - mysqlnd           - oauth             - openssl
- pcntl             - pcov              - pcre              - pdo
- pdo_mysql         - pdo_pgsql         - pdo_sqlite        - pgsql
- phar              - posix             - pspell            - psr
- rdkafka           - readline          - redis             - reflection
- session           - shmop             - simplexml         - soap
- sockets           - sodium            - spl               - sqlite3
- standard          - swoole            - sysvmsg           - sysvsem
- sysvshm           - tidy              - tokenizer         - uuid
- xdebug            - xhprof            - xml               - xmlreader
- xmlwriter         - xsl               - yaml              - zend opcache
- zip               - zlib
```

#### PHP7.4

The following PHP extensions are installed in `adhocore/phpfpm:7.4`:

```
Total: 86
- apcu              - ast               - bcmath            - bz2
- calendar          - core              - ctype             - curl
- date              - dom               - ds                - ev
- event             - exif              - fileinfo          - filter
- ftp               - gd                - gettext           - gmp
- grpc              - hash              - hrtime            - iconv
- igbinary          - imagick           - imap              - intl
- json              - ldap              - libxml            - lua
- lzf               - mbstring          - memcached         - mongodb
- msgpack           - mysqli            - mysqlnd           - oauth
- openssl           - pcntl             - pcov              - pcre
- pdo               - pdo_mysql         - pdo_pgsql         - pdo_sqlite
- pgsql             - phalcon           - phar              - posix
- psr               - rdkafka           - readline          - redis
- reflection        - session           - simplexml         - soap
- sockets           - sodium            - spl               - sqlite3
- ssh2              - standard          - swoole            - swoole_async
- sysvmsg           - sysvsem           - sysvshm           - tideways_xhprof
- tidy              - tokenizer         - uuid              - xdebug
- xlswriter         - xml               - xmlreader         - xmlwriter
- yaf               - yaml              - zend opcache      - zephir parser
- zip               - zlib
```

Read more about
[pcov](https://github.com/krakjoe/pcov),
[psr](https://github.com/jbboehr/php-psr)

### Production Usage

For production you may want to get rid of some extensions that are not really required.
In such case, you can build a custom image on top `adhocore/phpfpm:8.0` like so:

```Dockerfile
FROM adhocore/phpfpm:8.0

# Disable extensions you won't need. You can add as much as you want separated by space.
RUN docker-php-ext-disable xdebug pcov ldap
```

> `docker-php-ext-disable` is shell script available in `adhocore/phpfpm:8.0` only and not in official PHP docker images.
