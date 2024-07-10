FROM ubuntu:24.04 as Linux-builder

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/linux/tools/lib/bpf/:/usr/local/cargo/bin:/linux/rust/dist/bin:$PATH \
    LD_LIBRARY_PATH=/linux/tools/lib/bpf:$LD_LIBRARY_PATH \
    LINUX=/linux 

# adding clang
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -y git build-essential gcc g++ fakeroot libncurses5-dev libssl-dev ccache dwarves libelf-dev \
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
 libcap-dev libdisasm-dev binutils-dev unzip \
 pkg-config lsb-release wget software-properties-common gnupg zlib1g 

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
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon xterm attr busybox openssh-server

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-client openssh-server 

# Debugging
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tmux gdb 

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y strace 

# Moo kernel bcc and bpftrace
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y bpftrace 


