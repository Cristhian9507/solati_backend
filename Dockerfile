# # FROM webdevops/php-nginx:8.1-alpine
# FROM php:8.2-fpm

# # Install Laravel framework system requirements (https://laravel.com/docs/8.x/deployment#optimizing-configuration-loading)
# RUN apt-get oniguruma-dev postgresql-dev libxml2-dev
# # RUN docker-php-ext-install \
# #         bcmath \
# #         ctype \
# #         fileinfo \
# #         json \
# #         mbstring \
# #         pdo_mysql \
# #         pdo_pgsql \
# #         tokenizer \
# #         xml
# RUN apt-get update && apt-get install -y \
#     build-essential \
#     libpng-dev \
#     libjpeg62-turbo-dev \
#     libfreetype6-dev \
#     locales \
#     zip \
#     jpegoptim optipng pngquant gifsicle \
#     vim \
#     libzip-dev \
#     unzip \
#     git \
#     curl \
#     pdo_mysql \
#     pdo_pgsql \
#     libonig-dev

# # Clear cache
# RUN apt-get clean && rm -rf /var/lib/apt/lists/*
# # Install extensions
# RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
# RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg
# RUN docker-php-ext-install gd
# # Copy Composer binary from the Composer official Docker image
# COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ENV WEB_DOCUMENT_ROOT /app/public
# WORKDIR /app
# COPY . .

# RUN composer install --no-interaction --optimize-autoloader
# # Optimizing Configuration loading
# RUN php artisan config:cache
# # Optimizing Route loading
# RUN php artisan route:cache
# # Optimizing View loading
# RUN php artisan view:cache

# # permisos www-data
# RUN chown -R www-data:www-data \
#         /var/www/storage \
#         /var/www/bootstrap/cache

# # permisos carpetas storage
# RUN chmod 775 storage/logs \
#         /var/www/storage/framework/sessions \
#         /var/www/storage/framework/views

# RUN chown -R application:application .

FROM php:8.2-fpm

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    libzip-dev \
    unzip \
    git \
    curl \
    libonig-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN apt-get update
RUN apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-ansi --no-dev --no-interaction --no-progress --optimize-autoloader --no-scripts

# Copy existing application directory contents to the working directory
COPY . /var/www

# Assign permissions of the working directory to the www-data user
RUN chown -R www-data:www-data \
        /var/www/storage \
        /var/www/bootstrap/cache

# Assign writing permissions to logs and framework directories
RUN chmod 775 storage/logs \
        /var/www/storage/framework/sessions \
        /var/www/storage/framework/views
COPY ./run.sh /tmp
RUN chmod +x /tmp/run.sh
EXPOSE 80
CMD ["php-fpm", "/tmp/run.sh"]