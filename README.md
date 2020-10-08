## docker-phpfpm

Docker PHP FPM with lean alpine base. The download size is just about ~100MB.

It contains PHP8.0rc with plenty of common and useful extensions.

This version of PHP is not yet production ready.
You can still continue using [`adhocore/phpfpm:7.4`](https://github.com/adhocore/docker-phpfpm/tree/7.4) in production.

If you are looking for a complete local development stack then check
[`adhocore/lemp`](https://github.com/adhocore/docker-lemp).

## Usage
To pull latest image:

```sh
docker pull adhocore/phpfpm:8.0rc
```

To use in docker-compose
```yaml
# ./docker-compose.yml
version: '3'

services:
  phpfpm:
    image: adhocore/phpfpm:8.0rc
    container_name: phpfpm
    volumes:
      # Here you can also volume php ini settings
      # - /path/to/zz-overrides:/usr/local/etc/php/conf.d/zz-overrides.ini
    ports:
      - 9000:9000
    environment:
      # ...
```

### Extensions

The following PHP extensions are installed:

```
- apcu              - ast               - bcmath            - bz2
- calendar          - core              - ctype             - curl
- date              - dom               - exif              - fileinfo
- filter            - ftp               - gd                - gettext
- gmp               - hash              - iconv             - igbinary
- imap              - intl              - json              - ldap
- libxml            - lzf               - mbstring          - memcached
- mysqli            - mysqlnd           - openssl           - pcntl
- pcov              - pcre              - pdo               - pdo_mysql
- pdo_pgsql         - pdo_sqlite        - pgsql             - phar
- posix             - pspell            - psr               - readline
- reflection        - session           - shmop             - simplexml
- soap              - sockets           - sodium            - spl
- sqlite3           - standard          - sysvmsg           - sysvsem
- sysvshm           - tidy              - tokenizer         - uuid
- xml               - xmlreader         - xmlwriter         - xsl
- zend opcache      - zip               - zlib
```

Read more about
[pcov](https://github.com/krakjoe/pcov),
[psr](https://github.com/jbboehr/php-psr),

### Production Usage

Not yet ready for production usage.
