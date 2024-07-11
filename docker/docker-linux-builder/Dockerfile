FROM ubuntu:24.04 AS linux-builder

ENV PATH=/linux/tools/lib/bpf/:/usr/local/cargo/bin:/linux/rust/dist/bin:$PATH \
    LINUX=/linux

# adding clang
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -y git build-essential gcc g++ \
    fakeroot libncurses5-dev libssl-dev ccache dwarves libelf-dev \
 cmake \
 libdw-dev libdwarf-dev \
 bpfcc-tools libbpfcc-dev libbpfcc \
 linux-headers-generic \
 libtinfo-dev \
 libstdc++-11-dev libstdc++-12-dev libstdc++-13-dev libstdc++-14-dev \
 bc \
 flex bison \
 rsync \
 kmod \
 curl \
 libcap-dev libdisasm-dev binutils-dev unzip \
 pkg-config lsb-release wget software-properties-common gnupg zlib1g zlib1g-dev

RUN wget https://apt.llvm.org/llvm.sh
RUN chmod +x llvm.sh
RUN ./llvm.sh 18
RUN ln -s /usr/bin/clang-18 /usr/bin/clang
RUN ln -s /usr/bin/clang++-18 /usr/bin/clang++
RUN ln -s /usr/bin/ld.lld-18 /usr/bin/ld.lld
RUN ln -s /usr/bin/llvm-ar-18 /usr/bin/llvm-ar
RUN ln -s /usr/bin/llvm-strip-18 /usr/bin/llvm-strip
RUN ln -s /usr/bin/llvm-objdump-18 /usr/bin/llvm-objdump
RUN ln -s /usr/bin/llc-18 /usr/bin/llc
RUN ln -s /usr/bin/llvm-readelf-18 /usr/bin/llvm-readelf
RUN ln -s /usr/bin/llvm-dis-18 /usr/bin/llvm-dis
RUN ln -s /usr/bin/opt-18 /usr/bin/opt

# Qemu
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y qemu-kvm libvirt-clients libvirt-daemon-system  \
    bridge-utils virtinst libvirt-daemon xterm attr busybox openssh-server

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-client openssh-server

# Debugging
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tmux gdb

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y strace

# kernelwithbpfprograms kernel bcc and bpftrace
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y bpftrace

# nginx
ENV NGINX_VERSION=1.26.1 \
    NGINX_BIN=/usr/sbin/nginx \
    NGINX_CONF=/etc/nginx \
    NGINX_RUN=/var/www \
    NGINX_DIRS="${NGINX_BIN} ${NGINX_CONF} ${NGINX_RUN}"

# Update and install necessary packages
RUN apt-get update \
    && apt-get install -y vim libpcre3 libpcre3-dev libgd-dev  \
    libxml2 libxml2-dev uuid-dev xdp-tools wrk iproute2 net-tools lsof hping3

# Create necessary directories
RUN mkdir -p /downloads_nginx

# Download, extract, configure, and install NGINX
RUN cd /downloads_nginx \
    && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar xvzf ./nginx-${NGINX_VERSION}.tar.gz -C . \
    && cd nginx-${NGINX_VERSION} \
    && export CFLAGS="-Wno-error" \
    && ./configure \
        --prefix=${NGINX_RUN}/html \
        --sbin-path=${NGINX_BIN} \
        --conf-path=${NGINX_CONF}/nginx.conf \
        --with-pcre \
        --with-http_ssl_module \
        --with-http_image_filter_module=dynamic \
        --modules-path=/etc/nginx/modules \
        --with-http_v2_module \
        --with-stream=dynamic \
        --with-http_addition_module \
        --with-http_mp4_module \
    && make \
    && make install

# Expose port 80
EXPOSE 80

# start like this
# nginx -g 'daemon off;' and from another ssh-session (sudo make qemu-ssh do curl -I http://localhost:80
# wrk -t6 -c200 -d45s http://localhost:80/index.html