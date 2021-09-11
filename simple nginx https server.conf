```
server {
	listen 			443 ssl;
	listen 			[::]:443 ssl;
	server_name 	subdomain.domain.tld;

	ssl_certificate 	/path/to/certificate.pem
	ssl_certificate_key /path/to/private-key.pem;
	ssl_protocols		TLSv1 TLSv1.1 TLSv1.2;
	ssl_ciphers			HIGH:!aNULL:!MD5;

	location / {
		proxy_set_header 	Host $host;
		proxy_pass 			http://backend-server/;
		proxy_redirect 		off;
		proxy_set_header 	X-Real-IP $remote_addr;
		proxy_set_header 	X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header 	X-Forwarded-Proto https;
	}

	error_page 502 /logical/path/to/error502.html;
	location = /logical/path/to/error502.html {
		root /actual/path/to/error502.html;
		internal;
	}
}

server {
	listen 80;
	listen [::]:80;
	
	server_name subdomain.domain.tld;
	return 301 https://subdomain.domain.tld$request_uri;
}
```
