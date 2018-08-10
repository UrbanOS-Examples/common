proxy_cache_path /tmp/nginx_cache levels=1:2 keys_zone=cache:30m max_size=250m;
proxy_temp_path /tmp/nginx_proxy 1 2;

server {
    client_max_body_size 100M;
    listen 80;
    server_name ckan.smartcolumbusos.com;
    server_name ckan.*.internal.smartcolumbusos.com;

    set_real_ip_from 0.0.0.0/0;
    real_ip_header X-Forwarded-For;
    real_ip_recursive on;
    proxy_set_header X-Real-IP $remote_addr;

    add_header Content-Security-Policy "frame-ancestors *.smartcolumbusos.com smartcolumbusos.com";
    add_header X-XSS-Protection "1; mode=block";
    add_header x-frame-options "ALLOW-FROM https://www.sandbox.smartcolumbusos.com";
    server_tokens off; #disable nginx version headers
    add_header X-Content-Type-Options nosniff;

    location / {
        proxy_pass http://127.0.0.1:8080/;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $host;
        proxy_cache cache;
        proxy_cache_bypass $cookie_auth_tkt;
        proxy_no_cache $cookie_auth_tkt;
        proxy_cache_valid 30m;
        proxy_cache_key $host$scheme$proxy_host$request_uri;
        proxy_set_header X-Forwarded-Proto $scheme;
        # In emergency comment out line to force caching proxy_ignore_headers X-Accel-Expires 
        # Expires Cache-Control; Any request that did not originally come in to the ELB over
        # HTTPS gets redirected.
        if ($http_x_forwarded_proto != "https") {
            rewrite ^(.*)$ https://$server_name$REQUEST_URI permanent;
        }
    }

    #force all api calls to go through kong
    location /api {
        #nginx by default does not use the system DNS - you must set the resolver here
        resolver #{NAMESERVER}; # Uses #{} so that it can be replaced at "runtime"
        proxy_pass http://kong.${DNS_ZONE}/ckan$request_uri;
        proxy_redirect http://kong.${DNS_ZONE}/ckan$request_uri /api/;
    }

    location /user/login {
        #block access to the login screen unless the requests is from the internal VPN
        set $allow false;
        if ($http_x_forwarded_for ~ "^10.0.") { set $allow true; }
        if ($allow = false) {
            return 404;
        }
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_pass http://127.0.0.1:8080/user/login;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        # In emergency comment out line to force caching proxy_ignore_headers
        # X-Accel-Expires Expires Cache-Control; Any request that did not origin
        if ($http_x_forwarded_proto != "https") {
            rewrite ^(.*)$ https://$server_name$REQUEST_URI permanent;
        }
    }

    location /user/logged_in {
        #block access to the login screen unless the requests is from the internal VPN
        set $allow false;
        if ($http_x_forwarded_for ~ "^10.0.") { set $allow true; }
        if ($allow = false) {
            return 404;
        }
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_pass http://127.0.0.1:8080/user/logged_in;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        # In emergency comment out line to force caching proxy_ignore_headers
        # X-Accel-Expires Expires Cache-Control; Any request that did not origin
        if ($http_x_forwarded_proto != "https") {
            rewrite ^(.*)$ https://$server_name$REQUEST_URI permanent;
        }
    }

    location /login_generic {
        #block access to the login screen unless the requests is from the internal VPN
        set $allow false;
        if ($http_x_forwarded_for ~ "^10.0.") { set $allow true; }
        if ($allow = false) {
            return 404;
        }
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_pass http://127.0.0.1:8080/login_generic;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        # In emergency comment out line to force caching proxy_ignore_headers
        # X-Accel-Expires Expires Cache-Control; Any request that did not origin
        if ($http_x_forwarded_proto != "https") {
            rewrite ^(.*)$ https://$server_name$REQUEST_URI permanent;
        }
    }

    #allow port 80 non HTTP for health check
    location /health_check {
        proxy_pass http://127.0.0.1:8080/health_check;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $host;
        proxy_cache cache;
        proxy_cache_bypass $cookie_auth_tkt;
        proxy_no_cache $cookie_auth_tkt;
        proxy_cache_valid 30m;
        proxy_cache_key $host$scheme$proxy_host$request_uri;
        proxy_set_header X-Forwarded-Proto $scheme;
        access_log off;
        break;
    }
}