FROM nextcloud:30.0.5
RUN apt-get update
RUN apt-get install -y ghostscript
RUN apt install -y libmagickwand-dev --no-install-recommends
RUN pecl install imagick; exit 0
RUN docker-php-ext-enable imagick
RUN rm -rf /var/lib/apt/lists/*
