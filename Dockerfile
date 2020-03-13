# download Cloud SQL proxy
FROM gcr.io/cloud-builders/wget AS fetcher
CMD ['-O', 'cloud_sql_proxy', 'https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64']

# https://github.com/docker-library/wordpress/blob/9ee913eea382b5d79f852a2301d4390904d2e4d2/php7.3/apache/Dockerfile
FROM wordpress:5.2.1-php7.3-apache

ENV PORT 80
RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

# wordpress conf
COPY wordpress/wp-config.php /var/www/html/wp-config.php

COPY --from=fetcher cloud_sql_proxy /usr/local/bin/cloud_sql_proxy
RUN chmod +x /usr/local/bin/cloud_sql_proxy

# custom entrypoint
COPY wordpress/cloud-run-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["cloud-run-entrypoint.sh","docker-entrypoint.sh"]
# Use the PORT environment variable in Apache configuration files.
CMD sed -i "s/80/$PORT/g" /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf && \
    echo "RUNNING apache2 on port: ${PORT}" && \
    apache2-foreground
