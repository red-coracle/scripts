#!/bin/bash
# https://gist.github.com/Belphemur/3c022598919e6a1788fc
# https://gist.github.com/iamkingsleyf/75466d24dc35c02af604
# https://gist.github.com/MattWilcox/402e2e8aa2e1c132ee24

SELFRANDO_BIN="/home/deploy/build/selfrando/out/x86_64/bin"
LDFLAGS="-Wl,-rpath,$SELFRANDO_BIN -Wl,--gc-sections"
SR_OPT_="-O2 -fPIE -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4"
LD_OPT="-Wl,-z,relro -Wl,-E -Wl,-rpath,/usr/local/lib"

NPS_VERSION=1.13.35.2-stable
LIBRESSL_VERSION=2.8.3
NGINX_VERSION=1.15.8
PCRE_VERSION=8.42
ZLIB_VERSION=1.2.11

if [[ "${1}" == "clean" ]]; then
  sudo rm -rf libressl-${LIBRESSL_VERSION}* nginx-${NGINX_VERSION}* ngx_pagespeed-${NPS_VERSION} v${NPS_VERSION}.zip pcre*
  exit 0
fi

export BPATH=$(pwd)
export STATICLIBSSL=$BPATH/libressl-$LIBRESSL_VERSION

if [[ ! -f "v${NPS_VERSION}.zip" ]]; then
  wget https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}.zip
  unzip v${NPS_VERSION}.zip
  cd incubator-pagespeed-ngx-${NPS_VERSION}/
  NPS_RELEASE_NUMBER=${NPS_VERSION/stable/}
  psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz
  [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
  wget ${psol_url}
  tar -xzvf $(basename ${psol_url})
  cd ..
fi

if [[ ! -f "libressl-${LIBRESSL_VERSION}.tar.gz" ]]; then
  wget http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz
  wget http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz.asc
  gpg --verify libressl-${LIBRESSL_VERSION}.tar.gz.asc libressl-${LIBRESSL_VERSION}.tar.gz 2>/dev/null
  if [ $? -eq 0 ]; then
    tar -xzvf libressl-${LIBRESSL_VERSION}.tar.gz
    cd $STATICLIBSSL
    #./configure LDFLAGS=-lrt --prefix=${STATICLIBSSL}/.openssl/ && make install-strip -j 2
    ./configure CPPFLAGS="-O3 -fPIE -fstack-protector-strong -Werror=format-security $ECFLAG" LDFLAGS="-Wl,-Bsymbolic-functions -Wl,-z,relro" --prefix=${STATICLIBSSL}/.openssl/
    make install-strip -j 2
    cd ..
  else
    echo "LibreSSL signature verification failed"
    exit 1
  fi
fi

if [[ ! -f "pcre-${PCRE_VERSION}.tar.gz" ]]; then
  wget https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz
  wget https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz.sig
  gpg --verify pcre-${PCRE_VERSION}.tar.gz.sig pcre-${PCRE_VERSION}.tar.gz 2>/dev/null
  if [ $? -eq 0 ]; then
    tar -xzvf pcre-${PCRE_VERSION}.tar.gz
  else
    echo "PCRE signature verification failed"
    exit 1
  fi
fi

# git clone https://github.com/SpiderLabs/ModSecurity.git modsecurity
#cd modsecurity
#git pull
#git submodule init
#git submodule update
#if [[ "${1}" == "build" ]]; then
#  ./build
#  ./configure --enable-standalone-module --disable-mlogc
#  make -j2
#fi
#cd ..

# For nginx
if [[ ! -f "nginx-${NGINX_VERSION}.tar.gz" ]]; then
  wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
  tar -xvzf nginx-${NGINX_VERSION}.tar.gz
fi

if gcc -dM -E - </dev/null | grep -q __SIZEOF_INT128__; then
  ECFLAG="enable-ec_nistp_64_gcc_128"
else
  ECFLAG=""
fi

if [[ "${1}" == "build" ]]; then
  cd nginx-${NGINX_VERSION}/
  ./configure \
   --prefix=/usr/local/share/nginx \
   --conf-path=/etc/nginx/nginx.conf \
   --sbin-path=/usr/local/sbin \
   --error-log-path=/var/log/nginx/error.log \
   --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
   --pid-path=/run/nginx.pid \
   --lock-path=/var/lock/nginx.lock \
   --with-cc-opt="-O3 -fPIE -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4" \
   --with-ld-opt="$LD_OPT" \
   --add-module=../incubator-pagespeed-ngx-${NPS_VERSION} \
   --add-module=../modsecurity-nginx \
   --add-module=../nginx-module-vts \
   --add-module=../replace-filter-nginx-module \
   --add-module=../nginx-rtmp-module \
   --with-openssl=../libressl-${LIBRESSL_VERSION} \
   --with-pcre=../pcre-${PCRE_VERSION} \
   --with-http_gzip_static_module \
   --with-http_addition_module \
   --with-http_gunzip_module \
   --with-http_stub_status_module \
   --with-http_realip_module \
   --with-http_auth_request_module \
   --with-http_secure_link_module \
   --with-http_ssl_module \
   --with-http_v2_module \
   --with-http_realip_module \
   --with-http_geoip_module \
   --with-threads \
   --with-file-aio \
   --with-pcre-jit \
   --without-http_geo_module \
   --without-http_scgi_module \
   --without-mail_pop3_module \
   --without-mail_smtp_module \
   --without-mail_imap_module

  touch $STATICLIBSSL/.openssl/include/openssl/ssl.h
  make -j2
  cd ..
fi

if [[ "${1}" == "install" ]]; then
  cd nginx-${NGINX_VERSION}/
  sudo service nginx stop
  sudo checkinstall --pkgname="nginx-libressl" --pkgversion="$NGINX_VERSION" \
   --provides="nginx" --requires="libc6, libpcre3, zlib1g" --strip=yes \
   --stripso=yes --backup=yes -y --install=yes
  sudo service nginx start
  cd ..
fi

#sudo rm -rf libressl-${LIBRESSL_VERSION}* nginx-${NGINX_VERSION}* ngx_pagespeed-${NPS_VERSION} v${NPS_VERSION}.zip pcre*
