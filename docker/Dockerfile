FROM openeuler/openeuler:22.03-lts
MAINTAINER openGauss-ml@openguass.org
LABEL MAIL="heguofeng@huawei.com" \
      CREATE_DATE="2022-10" \
      GAUSS_SERVER="openGauss-5.0.0"

RUN \
    sed -i "s/gpgcheck=1/gpgcheck=0/g" /etc/yum.repos.d/openEuler.repo && \
    sed -i "s#http://repo.openeuler.org#https://mirrors.huaweicloud.com/openeuler#g" /etc/yum.repos.d/openEuler.repo  && \
    yum install -y -q net-tools wget sudo shadow vim bc util-linux git && \
    useradd opengauss && \
    sed -i "101i opengauss ALL=(ALL) NOPASSWD:ALL" /etc/sudoers && \
    sed -i "s/TMOUT=300/TMOUT=0/g" /etc/bashrc && \
    cp -rf /usr/share/zoneinfo/Asia/Beijing /etc/localtime && \
    yum install -y python -q tzdata cmake libaio-devel ncurses-devel pam-devel libffi-devel libtool \
    libtool-ltdl openssl-devel bison flex glibc-devel patch unzip openeuler-lsb make automake xz && \
    yum clean all

WORKDIR /home/opengauss
COPY --chown=opengauss:opengauss . /home/opengauss

USER opengauss:opengauss

RUN cp -f /home/opengauss/bashrc /home/opengauss/.bashrc && \
    cd /home/opengauss && \
    if [ "`uname -m`" == "x86_64" ]; then \
        wget -q https://opengauss.obs.cn-south-1.myhuaweicloud.com/5.0.0/binarylibs/openGauss-third_party_binarylibs_openEuler_x86_64.tar.gz -O openGauss_third.tar.gz; \
    else \
        wget -q https://opengauss.obs.cn-south-1.myhuaweicloud.com/5.0.0/binarylibs/openGauss-third_party_binarylibs_openEuler_arm.tar.gz -O openGauss_third.tar.gz; \
    fi && \
    tar -xf openGauss_third.tar.gz && mv openGauss-third_party_binarylibs* binarylibs && rm -f openGauss_third.tar.gz && \
    curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash -s -- -v 0.11.2 && source /home/opengauss/.bashrc && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && source "$HOME/.cargo/env" && \
    rustup target add wasm32-unknown-unknown && \
    cargo install wasm-gc && source /home/opengauss/.bashrc && \
    wget -q https://gitee.com/opengauss/openGauss-server/repository/archive/v5.0.0.zip && unzip -q v5.0.0.zip && rm -rf v5.0.0.zip && \
    cd openGauss-server-v5.0.0 && \
    ./configure --gcc-version=7.3.0 CC=g++ CFLAGS='-O2' \
        --prefix=$GAUSSHOME --3rd=$BINARYLIBS \
        --enable-cassert --enable-thread-safety \
        --without-readline --without-zlib  && \
    make -sj 8 && make install -sj 8 && \
    cd /home/opengauss && git clone https://gitee.com/Nelson-He/openGauss-wasm.git -b wasmedge && \
    cp -rf openGauss-wasm/wasm  openGauss-server-v5.0.0/contrib && \
    cd openGauss-server-v5.0.0/contrib/wasm && make && make install && \
    cd /home/opengauss && \
    chmod +x /home/opengauss/entrypoint.sh && \
    cp -rf /home/opengauss/openGauss-server-v5.0.0/contrib/wasm/examples/*  /home/opengauss && \
    sudo rm -rf /home/opengauss/binarylibs && \
    sudo rm -rf /home/opengauss/openGauss-server-v5.0.0 && \ 
    sudo rm -rf /home/opengauss/openGauss-wasm && \
    sudo yum remove -y make cmake git && \
    sudo yum clean all

ENTRYPOINT ["/bin/bash", "/home/opengauss/entrypoint.sh"]

CMD ["bash"]
