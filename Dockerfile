FROM php:8.2-cli

# Dependencias del sistema
RUN apt-get update && apt-get install -y \
    git unzip zip \
    libzip-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    libonig-dev libxml2-dev

# Extensiones PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql zip gd

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

# 🔴 IMPORTANTE: crear carpetas necesarias
RUN mkdir -p bootstrap/cache storage/framework storage/framework/cache storage/framework/sessions storage/framework/views

# permisos
RUN chmod -R 775 storage bootstrap/cache

RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction

# Permisos
RUN chmod -R 775 storage bootstrap/cache

# Cache Laravel (seguro)
RUN php artisan config:clear || true
RUN php artisan route:clear || true
RUN php artisan view:clear || true

EXPOSE 8080

CMD ["php","artisan","serve","--host=0.0.0.0","--port=8080"]
