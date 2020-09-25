FROM php:7.3.6-fpm-alpine3.9

#A instalação do pacote shadow para habilitar o comando usermod
RUN apk add --no-cache openssl bash mysql-client nodejs npm
RUN docker-php-ext-install pdo pdo_mysql
RUN apk add shadow && usermod -u 1000 www-data

# já que o docker-compose v3 não reconhece depends_on/condition no yaml, o dockerize fará esse papel
# código pego do site https://github.com/jwilder/dockerize para instalar
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz
# fim  do dockerize

WORKDIR /var/www
RUN rm -rf /var/www/html
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer 
# RUN composer install && \
#     cp .env.example .env && \
#     php artisan key:generate && \
#     php artisan config:cache
# COPY . /var/www # no docker-compose está configurado para volume compartilhado

#Atribuir a arquivos e pastas que a propriedade é do usuário www-data, 
# como foi feito um COPY antes com o root, os arquivos                  
# são dele e o www-data não teria permissão para escrever e modificar arquivos. 
RUN chown -R www-data:www-data /var/www

RUN ln -s public 

#Atribuição do grupo 1000 ao usuário www-data
RUN usermod -u 1000 www-data

#Atribuição do usuário www-data como usuário padrão em vez do root
USER www-data

# de agora em diante tudo que for criado com www-data pertencerá ao usuário da sua máquina, 
# resolvendo futuros problemas de "Permission Denied".

EXPOSE 9000
ENTRYPOINT ["php-fpm"]
