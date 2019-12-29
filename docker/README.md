# Packages

## Custom images

- php-fpm
    - extends php:fpm-alpine
    - all notable php extensions
    
- server
    - extends php-fpm 
    - cron
    - supervisor
    - certbot
    - terminal utils
    
- server-dev
    - extends server
    - xdebug
    - ast

- nginx
    - extends alpine
    - nginx with lua


## Community images

- mysql (5.7)
- redis (4.0)


## Build

```bash
docker build -t tkanstantsin/userver-nginx:4.7-nginx1.17.7-alpine3.11 -f docker/Dockerfile-nginx ./docker

docker build -t tkanstantsin/userver-php-fpm:4.7-php7.3.13-alpine3.11 -f docker/Dockerfile-php-fpm-alpine ./docker
docker build -t tkanstantsin/userver-php:4.7-php7.3.13-alpine3.11 -f docker/Dockerfile-server-alpine ./docker
docker build -t tkanstantsin/userver-php:4.7-php7.3.13-alpine3.11-dev -f docker/Dockerfile-server-alpine-dev ./docker
```


## Image naming

`<namespace><image>:<version>-<main program name><program version>-<os><os version>[-dev]`

Examples:

- `tkanstantsin/userver-nginx:4.7-nginx1.17.7-alpine3.11`
- `tkanstantsin/userver-php-fpm:4.7-php7.3.13-alpine3.11`
- `tkanstantsin/userver-php:4.7-php7.3.13-alpine3.11`
- `tkanstantsin/userver-php:4.7-php7.3.13-alpine3.11-dev`
