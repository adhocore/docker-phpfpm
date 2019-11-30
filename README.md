## docker-phpfpm

Docker PHP FPM with lean alpine base.
It contains PHP7.4.0 with plenty of common extensions.

## Usage
To pull latest image:

```sh
docker pull adhocore/phpfpm:7.4
```

To use in docker-compose
```yaml
# ./docker-compose.yml
version: '3'

services:
  phpfpm:
    image: adhocore/phpfpm:7.4
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
bcmath
bz2
calendar
Core
ctype
curl
date
dom
exif
fileinfo
filter
ftp
gd
gettext
gmp
hash
iconv
imagick
intl
json
ldap
libxml
mbstring
mysqli
mysqlnd
openssl
pcre
PDO
pdo_mysql
pdo_sqlite
Phar
posix
readline
redis
Reflection
session
SimpleXML
soap
sodium
SPL
sqlite3
standard
tideways_xhprof
tokenizer
xdebug
xml
xmlreader
xmlwriter
yaml
Zend OPcache
zip
zlib
```

`phalcon` has been removed as it conflicted with `pcre` in `PHP7.4`.

Read more about [tideways](https://github.com/tideways/php-xhprof-extension).
