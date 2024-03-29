FROM php:8.0.6-fpm

ARG APP_CODE_PATH_HOST=./code
ARG APP_CODE_PATH_CONTAINER=/var/www
# Copy composer.lock and composer.json
COPY ${APP_CODE_PATH_HOST}/composer.lock ${APP_CODE_PATH_HOST}/composer.json ${APP_CODE_PATH_CONTAINER}/

# Set working directory
WORKDIR ${APP_CODE_PATH_CONTAINER}

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
    unzip \
    git \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# # Install extensions
# RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
# RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
# RUN docker-php-ext-install gd

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions mbstring pdo_mysql zip exif pcntl gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY ${APP_CODE_PATH_HOST} ${APP_CODE_PATH_CONTAINER}

# Copy existing application directory permissions
COPY --chown=www:www ${APP_CODE_PATH_HOST} ${APP_CODE_PATH_CONTAINER}

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]