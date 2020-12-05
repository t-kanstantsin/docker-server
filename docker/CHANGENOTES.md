# Changes

# 4.9.0 - php7.4.12 - nginx1.19.5 - alpine3.11

- alpine:
    - php-fpm
        - added oniguruma for mbstring
        - remove wddx (deprecated) and recode (moved to pecl)
    - server
    - server-dev
    - nginx
        
`tkanstantsin/userver-nginx:4.9.0`
`tkanstantsin/userver-php-fpm:4.9.0`
`tkanstantsin/userver-php:4.9.0`
`tkanstantsin/userver-php:4.9.0`

# 4.8 - php7.3.13 - nginx1.17.6 - alpine3.11

- alpine:
    - php-fpm
    - server
    - server-dev
    - nginx
        - do not use daemon process
        
* `tkanstantsin/userver-nginx:4.8.0`
* `tkanstantsin/userver-php-fpm:4.8.0`
* `tkanstantsin/userver-php:4.8.0`
* `tkanstantsin/userver-php:4.8.0`


# 4.7 - php7.3.13 - nginx1.17.6 - alpine3.11

- alpine:
    - php-fpm
        - php:7.3.13-fpm-alpine3.11
    - server
        - supervisor:4
    - server-dev
        - ast:1.0.5
        - disable xdebug by default
    - nginx
        - alpine:3.11
        - nginx:1.17.6
        - devel-kit:0.3.1
        - lua-module:0.10.15
        - lua-jit:2.1
        - lua-redis:0.27

`tkanstantsin/userver-nginx:4.7-nginx1.17.7-alpine3.11`
`tkanstantsin/userver-php-fpm:4.7-php7.3.13-alpine3.11`
`tkanstantsin/userver-php:4.7-php7.3.13-alpine3.11`
`tkanstantsin/userver-php:4.7-php7.3.13-alpine3.11-dev`


# 4.5 - php7.3.2 - nginx1.15.7 - alpine3.9

- alpine
    - php-fpm
        - php:7.3.2-fpm-alpine3.9
        - gd exif ldap bcmath gmp opcache intl iconv mbstring dba mysqli pgsql pdo_mysql pdo_pgsql soap bz2 zip tidy pspell enchant calendar gettext xmlrpc wddx shmop sysvmsg sysvsem sysvshm sockets shmop pcntl xsl recode snmp
        - imagick yaml
    - server
        - bash coreutils mc htop curl rsyslog
        - certbot
        - python3 supervisor4
    - server-dev
        - xdebug
    - nginx 
        - lua-jit:0.10.15
        - alpine:3.8
        - nginx:1.15.7
        - devel-kit:0.3.0
        - lua-module:0.10.12rc2
        - lua-jit:2.1
        - lua-redis:0.26
