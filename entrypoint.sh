#!/bin/sh

# Percorso della cartella WordPress
WORDPRESS_PATH="/var/www/html"
WP_CONFIG="$WORDPRESS_PATH/wp-config.php"

# Controlla se la cartella è vuota e scarica WordPress se necessario
if [ ! -f "$WP_CONFIG" ]; then
    echo "📥 Scaricamento di WordPress..."
    curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz
    tar -xzf wordpress.tar.gz --strip-components=1 -C "$WORDPRESS_PATH"
    rm wordpress.tar.gz
    echo "✅ WordPress scaricato e installato."
    
    # Crea il file wp-config.php
    echo "📝 Creazione di wp-config.php..."
    cat > "$WP_CONFIG" <<EOL
<?php
define('DB_NAME', getenv('WORDPRESS_DB_NAME') ?: 'wordpress');
define('DB_USER', getenv('WORDPRESS_DB_USER') ?: 'root');
define('DB_PASSWORD', getenv('WORDPRESS_DB_PASSWORD') ?: '');
define('DB_HOST', getenv('WORDPRESS_DB_HOST') ?: 'localhost');

define('WP_DEBUG', getenv('WORDPRESS_DEBUG') === 'true');
define('WP_ENVIRONMENT_TYPE', getenv('WP_ENVIRONMENT_TYPE') ?: 'production');
define('WP_ALLOW_APPLICATION_PASSWORDS', getenv('WP_ALLOW_APPLICATION_PASSWORDS') === 'true');

\$table_prefix = 'wp_';
define('FS_METHOD', 'direct');

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOL
    echo "✅ wp-config.php creato."

    # Imposta i permessi
    echo "🛡️ Impostazione dei permessi..."
    chown -R www-data:www-data "$WORDPRESS_PATH"
    chmod -R 755 "$WORDPRESS_PATH"
    echo "✅ Permessi impostati."
else
    echo "✅ WordPress già presente, nessun download necessario."
fi

 echo "🛡️ Impostazione dei permessi..."
    chown -R www-data:www-data "$WORDPRESS_PATH"
    chmod -R 755 "$WORDPRESS_PATH"
    echo "✅ Permessi impostati."

# Avvio di Nginx e PHP-FPM
echo "🚀 Avvio di Nginx e PHP-FPM..."
nginx &
php-fpm -F
