FROM php:7.1-apache

RUN apt-get update \
    && apt-get install -y \
        libssl-dev \
        libicu-dev \
        libmcrypt-dev \
        libapache2-mod-rpaf \
        cron \
        sudo \
        acl \
    && docker-php-ext-install \
        intl \
        mbstring \
        mcrypt \
        pdo_mysql \
        zip \
        opcache \
    && pecl install xdebug \
    && rm /tmp/* -rf \
    && rm -r /var/lib/apt/lists/*

COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY sync-vendor.php /usr/local/bin/sync-vendor

ENV PATH "/composer/vendor/bin:/composer/home/vendor/bin:$PATH"
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer/home

RUN curl -sS https://getcomposer.org/installer | php -- \
      --install-dir=/usr/local/bin \
      --filename=composer \
    && composer global require phing/phing ~2.0 \
    && mkdir /composer/vendor \
    && echo "{ }" > /composer/home/config.json \
    && composer config --global vendor-dir /composer/vendor \
    && chmod 744 /usr/local/bin/sync-vendor \
    && chmod 644 /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

VOLUME [ "/composer/home/cache" ]
