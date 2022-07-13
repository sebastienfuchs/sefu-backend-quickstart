ARG PHP_VERSION
ARG COMPOSER_VERSION

FROM composer:${COMPOSER_VERSION} as composer
FROM php:${PHP_VERSION}-apache

LABEL org.opencontainers.image.authors="sebastienfuchs.net"

# install required packages
RUN apt-get update &&  \
    apt-get install -qy \
	git \
	unzip \
	gnupg \
	zip \
    make \
    bash \
    curl \
    openssh-client \
    autoconf \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && apt-get install -y --no-install-recommends wget vim supervisor libfreetype6-dev libjpeg62-turbo-dev \
    libmcrypt-dev libpng-dev libssl-dev libaio1 git libcurl4-openssl-dev libxslt-dev \
    libldap2-dev libicu-dev libc-client-dev libkrb5-dev libsqlite3-dev libedit-dev \
    sudo zlib1g zlib1g-dev libzip4 libzip-dev zip unzip librabbitmq-dev musl-dev && \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) bcmath gd pdo_mysql calendar exif gettext shmop soap sockets intl pcntl xsl ldap imap pdo

# Brotli
RUN git clone --recursive --depth=1 https://github.com/kjdev/php-ext-brotli.git && cd php-ext-brotli && \
    phpize &&  ./configure && make install clean

# AMQp
RUN apt-get update && apt-get install -y -f librabbitmq-dev libssh-dev \
    && docker-php-source extract \
    && mkdir /usr/src/php/ext/amqp \
    && curl -L https://github.com/php-amqp/php-amqp/archive/master.tar.gz | tar -xzC /usr/src/php/ext/amqp --strip-components=1 \
    && docker-php-ext-install amqp \
    && docker-php-ext-enable amqp

# xDebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Zip
RUN pecl install zip && \
    docker-php-ext-enable zip

# Redis
RUN pecl install redis && \
    docker-php-ext-enable redis

# Opcache
RUN docker-php-ext-install opcache && \
    echo "opcache.enable=0" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo "opcache.enable_cli=0" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

RUN a2enmod ssl rewrite

# COMPOSER
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Symfony CLI

RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash && \
    apt install symfony-cli

EXPOSE 80
EXPOSE 443