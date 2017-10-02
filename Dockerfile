FROM debian:stretch

ENV PATH $PATH:/usr/local/avr/bin
ENV GCC_VERSION 7.2.0
ENV LIBC_VERSION 2.0.0
ENV BINUTILS_VERSION 2.29.1
ENV CMAKE_VERSION 3.9.3

# export PATH=$PATH:/usr/local/avr/bin
# export GCC_VERSION=7.2.0
# export LIBC_VERSION=2.0.0
# export BINUTILS_VERSION=2.29.1
# export CMAKE_VERSION=3.9.3

RUN \
    #### install local build tools ####
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wget make build-essential libmpc-dev libmpfr-dev libgmp3-dev && \
    #### create build folder ####
    mkdir -p /usr/local/avr /tmp/build && cd /tmp/build && \
    #### download and build cmake ####
    CMAKE_MAJOR_VER=`echo $CMAKE_VERSION | cut -d. -f1` && \
    CMAKE_MINOR_VER=`echo $CMAKE_VERSION | cut -d. -f2` && \
    wget --no-check-certificate https://cmake.org/files/v${CMAKE_MAJOR_VER}.${CMAKE_MINOR_VER}/cmake-${CMAKE_VERSION}.tar.gz && \
    tar -zxvf cmake-${CMAKE_VERSION}.tar.gz && cd cmake-${CMAKE_VERSION} && \
    ./bootstrap && make -j$(nproc --all) && make install && cd .. && \
    #### download and build binutils ####
    wget http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.bz2 && \
    tar -jxvf binutils-${BINUTILS_VERSION}.tar.bz2 && cd binutils-${BINUTILS_VERSION} && \
    mkdir build && cd build && \
    ../configure --prefix=/usr/local/avr --target=avr --disable-nls && \
    make -j$(nproc --all) && make install && cd ../.. && \
    #### download and build gcc ####
    wget http://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz && \
    tar -zxvf gcc-${GCC_VERSION}.tar.gz && cd gcc-${GCC_VERSION} && \
    mkdir build && cd build && \
    ../configure --prefix=/usr/local/avr --target=avr --enable-languages=c,c++ --disable-nls --disable-libssp --with-dwarf2 && \
    make -j$(nproc --all) && make install && cd ../.. && \
    #### download and build avr-libc ####
    wget http://download.savannah.gnu.org/releases/avr-libc/avr-libc-${LIBC_VERSION}.tar.bz2 && \
    tar -jvxf avr-libc-${LIBC_VERSION}.tar.bz2 && cd avr-libc-${LIBC_VERSION} && \
    ./configure --prefix=/usr/local/avr --build=`./config.guess` --host=avr && \
    make -j$(nproc --all) && make install && cd .. && \
    #### clean up ####
    cd .. && rm -rf build && \
    apt-get remove -y wget build-essential libmpc-dev libmpfr-dev libgmp3-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /tmp/* /var/tmp/*
