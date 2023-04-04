FROM opensuse/tumbleweed

RUN zypper --non-interactive install createrepo nginx && \
    mkdir -p /var/www/html/repo

COPY ./rpm-packages/ /var/www/html/repo/

RUN createrepo /var/www/html/repo && \
    chown -R nginx:nginx /var/www/html/repo && \
    chmod -R 755 /var/www/html/repo && \
    rm -rf /etc/nginx/conf.d/default.conf

COPY ./nginx/nginx.conf /etc/nginx/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

