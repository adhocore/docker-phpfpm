#!/bin/sh

set -e

usage() {
  echo "usage: $0 [options] module-name [module-name ...]"
  echo "   ie: $0 apcu"
  echo "       $0 apcu redis"
  echo

  exit 1
}


modules=
for module; do
  [[ "$module" == "--help" ]] || [[ "$module" == "-h" ]] && usage >&2
  [[ -n "$modules" ]] && modules="$modules $module" || modules="$module"
done

[[ -n "$module" ]] || usage >&2

if ! command -v pickle &> /dev/null; then
  echo "Installing pickle"
  curl -sSLo /usr/local/bin/pickle https://github.com/FriendsOfPHP/pickle/releases/latest/download/pickle.phar
  chmod +x /usr/local/bin/pickle
fi

for module in $modules; do
  (php -m | grep -q $module && echo "$module already installed") \
    || (pickle install -n --defaults $module && docker-php-ext-enable $module > /dev/null)
done
