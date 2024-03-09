#!/bin/bash

# TmV2ZXIgZ29ubmEgZ2l2ZSB5b3UgdXAKTmV2ZXIgZ29ubmEgbGV0IHlvdSBkb3duCk5ldmVyIGdvbm5hIHJ1biBhcm91bmQgYW5kIGRlc2VydCB5b3UKTmV2ZXIgZ29ubmEgbWFrZSB5b3UgY3J5Ck5ldmVyIGdvbm5hIHNheSBnb29kYnllCk5ldmVyIGdvbm5hIHRlbGwgYSBsaWUgYW5kIGh1cnQgeW91

sys=$(command -v service || command -v systemctl || command -v rc-service)

for file in $(find / -name 'php.ini' 2>/dev/null); do
	sed -i "/^disable_functions/s/.*/disable_functions = 1e, exec, system, shell_exec, passthru, popen, curl_exec, curl_multi_exec, parse_file_file, show_source, proc_open, pcntl_exec/" $file
	echo "expose_php = Off" >> $file
	echo "track_errors = Off" >> $file
	echo "html_errors = Off" >> $file
	echo "file_uploads = Off" >> $file
	echo "max_execution_time = 3" >> $file
	echo "register_globals = off" >> $file
	echo "magic_quotes_gpc = on" >> $file
	echo "allow_url_fopen = off" >> $file
	echo "allow_url_include = off" >> $file
	echo "display_errors = off" >> $file
	echo "short_open_tag = off" >> $file
	echo "session.cookie_httponly = 1" >> $file
	echo "session.use_only_cookies = 1" >> $file
	echo "session.cookie_secure = 1" >> $file
	echo "expose_php = Off" >> $file
	echo "track_errors = Off" >> $file
	echo "html_errors = Off" >> $file
	echo "display_errors = Off" >> $file
	echo "magic_quotes_gpc = Off " >> $file
	echo "allow_url_fopen = Off" >> $file
	echo "allow_url_include = Off" >> $file
	echo "register_globals = Off" >> $file
	echo "file_uploads = Off" >> $file
	echo "session.cookie_httponly = 1" >> $file

	echo $file changed

done;



if [ -d /etc/nginx ]; then
	$sys nginx restart || $sys restart nginx
	echo nginx restarted
fi


if [ -d /etc/apache2 ]; then
	$sys apache2 restart || $sys restart apache2
	echo apache2 restarted
fi


if [ -d /etc/httpd ]; then
	$sys httpd restart || $sys restart httpd
	echo httpd restarted
fi

if [ -d /etc/lighttpd ]; then
	$sys lighttpd restart || $sys restart lighttpd
	echo lighttpd restarted
fi

if [ -d /etc/php/*/fpm ]; then
	$sys *php* restart || $sys restart *php*
	echo php-fpm restarted
fi
