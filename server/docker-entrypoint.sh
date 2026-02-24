#!/bin/bash
set -e

# Copy vendor from the build cache if it's missing (overwritten by volume mount)
if [ ! -d /var/www/html/vendor ]; then
    echo "==> Copying vendor folder from build cache..."
    cp -a /var/www/vendor-cache/. /var/www/html/vendor/
    echo "==> vendor folder ready."
fi

find /var/www/html -not -path '*/vendor/*' -exec chown www-data:www-data {} +

exec /usr/sbin/apache2ctl -D FOREGROUND
