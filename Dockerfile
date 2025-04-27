FROM ubuntu:22.04

ARG PHP_VERSION=8.4
ARG XDEBUG_YEAR=20240924
ARG COMPOSER_VERSION=2.8.8

#Sem interação humana
ARG DEBIAN_FRONTEND=noninteractive

#Updating operating system
RUN apt-get update && apt-get -y upgrade

##Installing essential packages
RUN apt-get -y install \
               apt-utils \
               software-properties-common \
               curl \
               sudo \
               bash \
               bash-completion \
               openssh-server \
               apt-utils \
               vim \
               git \
               zip \
               unzip \
               cron \
               libmagickwand-dev \
               libzip-dev \
               libpng-dev \
               libonig-dev \
               libxml2-dev

#Installing NGINX
RUN apt-get -y install nginx

#
COPY default /etc/nginx/sites-enabled/default

##Adding PHP repository
RUN add-apt-repository ppa:ondrej/php -y && apt-get update -y

RUN apt install php$PHP_VERSION-fpm -y

RUN update-alternatives --set php /usr/bin/php$PHP_VERSION

#Installing PHP and extensions
RUN apt-get -y install php$PHP_VERSION-redis php$PHP_VERSION-common php$PHP_VERSION-curl  \
php$PHP_VERSION-dev php$PHP_VERSION-mbstring php$PHP_VERSION-gd php$PHP_VERSION-redis php$PHP_VERSION-xml php$PHP_VERSION-zip php$PHP_VERSION-intl php$PHP_VERSION-mysql

# Install xdebug and redis
RUN apt-get install php$PHP_VERSION-xdebug -y && apt install php$PHP_VERSION-redis -y

#Configuring Xdebug
RUN echo "zend_extension=/usr/lib/php/$XDEBUG_YEAR/xdebug.so" >> /etc/php/$PHP_VERSION/fpm/php.ini

# Get latest Composer
RUN curl --insecure https://getcomposer.org/download/$COMPOSER_VERSION/composer.phar -o /usr/bin/composer && chmod +x /usr/bin/composer

# Install wget
RUN apt install wget -y

# Clean up
RUN rm -rf /tmp/pear \
    && apt-get purge -y --auto-remove \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE  80

WORKDIR /var/www/html

CMD service php8.4-fpm start && nginx -g "daemon off;"