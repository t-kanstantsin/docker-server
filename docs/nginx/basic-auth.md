# Basic auth

Basic auth in nginx works for every (sub)domain separately - for each domain `htpasswd` file must be created.


1. Execute following:


```bash
# From host machine
sh -c "echo -n '{USERNAME}:' > /var/www/html/docker/nginx/htpasswd/{DOMAIN_NAME}"
sh -c "openssl passwd -apr1 >> /var/www/html/docker/nginx/htpasswd/{DOMAIN_NAME}" 

# Inside nginx container
sh -c "echo -n '{USERNAME}:' > /etc/nginx/htpasswd/{DOMAIN_NAME}"
sh -c "openssl passwd -apr1 >> /etc/nginx/htpasswd/{DOMAIN_NAME}" 
```

1. Restart nginx container.
