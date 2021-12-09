# syntax=docker/dockerfile:1.3
FROM php:8.1-fpm as php-base

ARG USER_ID=1000
ARG GROUP_ID=1000

LABEL repository="https://github.com/Wojciechem/phperfect-dockerfile"

WORKDIR /app

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    # This allows apt to use build-time cache
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
    && apt update \
    && apt-get install --no-install-recommends -y unzip zip \
    && install-php-extensions apcu intl opcache pdo_mysql zip \
    && usermod -u $USER_ID www-data --shell /bin/bash \
    && groupmod -g $GROUP_ID www-data \
    && chown -R www-data:www-data /app
# ----
FROM php-base as php-dev

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

COPY --chown=www-data:www-data composer.* ./

USER www-data:www-data
RUN --mount=type=cache,id=composer,target=/root/.composer \
    composer install \
    --no-interaction \
    --optimize-autoloader
# ----
FROM php-base as php-prod

COPY --chown=www-data:www-data composer.* ./

USER www-data:www-data
RUN --mount=type=cache,id=composer,target=/root/.composer \
    composer install \
    --no-dev \
    --no-interaction \
    --optimize-autoloader

COPY --chown=www-data:www-data . ./
# ----
FROM php-prod as php-ci

RUN --mount=type=cache,id=composer,target=/root/.composer \
    composer install \
    --no-interaction \
    --optimize-autoloader