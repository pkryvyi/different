#!/bin/bash

yum install -y nginx
#Change selinux mode
#setenforce Permissive
#sed 's/enforcing/permissive/' /etc/selinux/config

#Backup and change config
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
echo "user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
# Load dynamic modules. See /usr/share/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}
http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;
        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;
  }      
" > /etc/nginx/nginx.conf

#Add config to conf.d
echo "  proxy_send_timeout 120;
  proxy_read_timeout 300;
  proxy_buffering    off;
    
  server {
    listen   *:80;
    server_name  _;
  
    # allow large uploads of files
    client_max_body_size 1G;
  
    # optimize downloading files larger than 1G
    #proxy_max_temp_file_size 2G;
  
    location / {
      proxy_pass http://localhost:8080/;
      proxy_set_header Host \$host;
      proxy_set_header X-Real-IP \$remote_addr;
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
  }" > /etc/nginx/conf.d/nexus.conf

#allow httpd in selinux
/usr/sbin/setsebool httpd_can_network_connect 1

#start nginx
systemctl enable nginx.service
systemctl daemon-reload
systemctl start nginx
