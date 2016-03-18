# Use Alpine Linux
FROM alpine:latest

# Timezone
ENV TIMEZONE America/Sao_Paulo
ENV PHP_MEMORY_LIMIT 512M
ENV MAX_UPLOAD 50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST 100M

COPY ./pkgs/php7redis-2.2.8-r0.apk /tmp/php7redis-2.2.8-r0.apk

RUN echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk add --update tzdata && \
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    apk add --update --allow-untrusted \
        nginx \
        supervisor \
        curl \
        git \
        openssh-client \
        bash \
        php7@testing \
        php7-dev@testing \
        php7-opcache@testing \
        php7-openssl@testing \
        php7-phar@testing \
        php7-mcrypt@testing \
        php7-mbstring@testing \
        php7-json@testing \
        php7-common@testing \
        php7-session@testing \
        php7-ctype@testing \
        php7-dom@testing \
        php7-fpm@testing  \
        php7-mongodb@testing \
        php7-xdebug@testing \
        /tmp/php7redis-2.2.8-r0.apk && \
    sed -i "s|;date.timezone =.*|date.timezone = ${TIMEZONE}|" /etc/php7/php.ini && \
    sed -i "s|memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|" /etc/php7/php.ini && \
    sed -i "s|upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|" /etc/php7/php.ini && \
    sed -i "s|max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|" /etc/php7/php.ini && \
    sed -i "s|post_max_size =.*|max_file_uploads = ${PHP_MAX_POST}|" /etc/php7/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php7/php.ini && \
    echo "xdebug.remote_enable=1" >> /etc/php7/conf.d/xdebug.ini && \
    echo "xdebug.remote_handler=dbgp" >> /etc/php7/conf.d/xdebug.ini && \
    echo "xdebug.remote_mode=req" >> /etc/php7/conf.d/xdebug.ini && \
    echo "xdebug.remote_port=9001" >> /etc/php7/conf.d/xdebug.ini && \
    echo "xdebug.remote_autostart=1" >> /etc/php7/conf.d/xdebug.ini && \
    echo "xdebug.remote_connect_back=1" >> /etc/php7/conf.d/xdebug.ini && \
    echo "xdebug.var_display_max_depth = -1 " >> /etc/php7/conf.d/xdebug.ini && \
    echo "xdebug.var_display_max_children = -1" >> /etc/php7/conf.d/xdebug.ini && \
    echo "xdebug.var_display_max_data = -1 " >> /etc/php7/conf.d/xdebug.ini && \
    echo "xdebug.remote_host="`/sbin/ip route|awk '/default/ { print $6 }'` >> /etc/php7/conf.d/xdebug.ini && \
    ln -sf /usr/bin/php7 /usr/bin/php && \
    curl --insecure -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/bin/composer && \
    mkdir /etc/nginx/sites-enabled && \
    sed -ri 's;^(root:x:0:0:root:/root:)/bin/ash;\1/bin/bash;' /etc/passwd && \
    echo "alias ll='ls -lha --color=auto'" >> /root/.bashrc && \
    echo "alias l='ls -lh --color=auto'" >> /root/.bashrc && \
    adduser -u 1000 docker -D -s /bin/bash && \
    cp /root/.bashrc /home/docker/.bashrc && \
    chown -R docker:docker /home/docker && \
    mkdir /www && \
    chown -R docker:docker /www && \
    apk del tzdata && \
    rm -fr /tmp/*.apk && \
    rm -rf /var/cache/apk/*

ADD ./conf/php-fpm.conf /etc/php7/php-fpm.conf
ADD ./conf/www.conf /etc/php7/php-fpm.d/www.conf
ADD ./conf/nginx.conf /etc/nginx/nginx.conf
ADD ./conf/supervisord.conf /etc/supervisord.conf
ADD ./conf/default.conf /etc/nginx/sites-enabled/default

# Set Workdir
WORKDIR /www

# Expose ports
EXPOSE 80 443

CMD ["/usr/bin/supervisord"]
