# 1️⃣ Base Image (Apache + PHP)
FROM php:8.2-apache

# 2️⃣ System dependencies
RUN apt-get update && apt-get install -y \
    curl \
    zip \
    unzip \
    git \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo_mysql mbstring exif bcmath gd

# 3️⃣ Enable Apache rewrite
RUN a2enmod rewrite

# 4️⃣ Set Document Root to /public
ENV APACHE_DOCUMENT_ROOT=/var/www/public
RUN sed -ri 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
 && sed -ri 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 5️⃣ Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 6️⃣ Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# 7️⃣ Working directory
WORKDIR /var/www

# 8️⃣ Copy project
COPY . .

# 9️⃣ Install PHP deps
RUN composer install --no-dev --optimize-autoloader

# 🔟 Storage link
RUN php artisan storage:link || true

# 1️⃣1️⃣ Build frontend
RUN npm install && npm run build

# 1️⃣2️⃣ Permissions
RUN chown -R www-data:www-data storage bootstrap/cache
