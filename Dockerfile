FROM php:7.3-fpm-alpine

# set main params
ARG BUILD_ARGUMENT_ENV=dev
ENV ENV=$BUILD_ARGUMENT_ENV
ENV APP_HOME /var/www/html

# check environment
RUN if [ "$BUILD_ARGUMENT_ENV" = "default" ]; then echo "Set BUILD_ARGUMENT_ENV in docker build-args like --build-arg BUILD_ARGUMENT_ENV=dev" && exit 2; \
    elif [ "$BUILD_ARGUMENT_ENV" = "dev" ]; then echo "Building development environment."; \
    elif [ "$BUILD_ARGUMENT_ENV" = "test" ]; then echo "Building test environment."; \
    elif [ "$BUILD_ARGUMENT_ENV" = "prod" ]; then echo "Building production environment."; \
    elif [ "$BUILD_ARGUMENT_ENV" = "stg" ]; then echo "Building staging environment."; \
    else echo "Set correct BUILD_ARGUMENT_ENV in docker build-args like --build-arg BUILD_ARGUMENT_ENV=dev. Available choices are dev,test,prod." && exit 2; \
    fi

# install all the dependencies and enable PHP modules
RUN apk update && apk upgrade && apk add \
    # procps \
    unzip \
    # libicu-dev \
    # zlib1g-dev \
    # libxml2 \
    # libxml2-dev \
    # libreadline-dev \
    supervisor \
    libzip-dev \
    libpng-dev \
    # nodejs \
    # npm \
    # && npm install n -g \
    # && n stable \
    # && apt purge -y nodejs npm \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-install pdo_mysql \
    # && docker-php-ext-install sockets \
    && docker-php-ext-install gd \
    && docker-php-ext-install mbstring \
    # intl \
    zip
# rm -fr /tmp/* && \
# rm -rf /var/list/apt/* && \
# rm -r /var/lib/apt/lists/* && \
# apt-get clean

# create document root
RUN mkdir -p $APP_HOME/public

# change owner
RUN chown -R www-data:www-data $APP_HOME

# put php config for Laravel
COPY ./docker/$BUILD_ARGUMENT_ENV/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./docker/$BUILD_ARGUMENT_ENV/php.ini /usr/local/etc/php/php.ini

# install composer
# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

# add supervisor
RUN mkdir -p /var/log/supervisor
COPY --chown=root:root ./docker/other/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# set working directory
WORKDIR $APP_HOME

# create composer folder for user www-data
# RUN mkdir -p /var/www/.composer && chown -R www-data:www-data /var/www/.composer

USER www-data

# copy source files and config file
COPY --chown=www-data:www-data ./ $APP_HOME/
COPY --chown=www-data:www-data ./.env $APP_HOME/.env

USER root
