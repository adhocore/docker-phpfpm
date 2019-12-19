#!/bin/sh
set -e

extDir=$(php -r 'echo ini_get("extension_dir");')
iniDir=$PHP_INI_DIR/conf.d/

usage() {
  echo "usage: $0 [options] module-name [module-name ...]"
  echo "   ie: $0 xdebug"
  echo "       $0 xdebug phalcon"
  echo
  echo 'Possible values for module-name:'
  cat $PHP_INI_DIR/conf.d/*.ini \
    | sed -E "s/(zend_|extension\=|${extDir//\//\\/}\/|\.so)//g" \
    | sort \
    | xargs
  echo

  exit 1
}

modules=
for module; do
  [[ "$module" == "--help" ]] \
    || [[ "$module" == "-h" ]] \
    && usage >&2
  [[ -n "$modules" ]] \
    && modules="$modules|(=|\/)$module.so" \
    || modules="(=|\/)$module.so"
done

[[ -n "$modules" ]] \
  && rmIni=$(grep -lE "$modules" $PHP_INI_DIR/conf.d/*.ini) \
  && echo "$rmIni" \
    | xargs rm
