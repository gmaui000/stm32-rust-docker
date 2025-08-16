FROM ubuntu:22.04

# Set timezone
ENV TZ=Asia/Shanghai
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

# Change source
RUN sed -i s@archive.ubuntu.com@mirrors.tuna.tsinghua.edu.cn@g /etc/apt/sources.list
RUN sed -i s@security.ubuntu.com@mirrors.tuna.tsinghua.edu.cn@g /etc/apt/sources.list

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -yq \
    git curl build-essential cmake \
    openocd gdb-multiarch libfuse2 stlink-tools libssl-dev pkg-config \
    libudev-dev libusb-dev libusb-1.0 usbutils

ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup
ENV PATH=$CARGO_HOME/bin:$RUSTUP_HOME/bin:$PATH

# add proxy
ENV http_proxy=http://192.168.31.164:7897
ENV https_proxy=http://192.168.31.164:7897

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

COPY ./config.yaml ${CARGO_HOME}/cargo/

RUN cargo install cargo-binutils \
    && cargo install flip-link \
    && cargo install probe-rs-tools --locked \
    && cargo install cargo-generate \
    && rustup component add llvm-tools-preview \
    && rustup component add rust-analyzer \
    && rustup component add rust-src \
    && rustup target add thumbv6m-none-eabi \
    && rustup target add thumbv7m-none-eabi \
    && rustup target add thumbv7em-none-eabi \
    && rustup target add thumbv7em-none-eabihf \
    && rustup target add thumbv8m.base-none-eabi \
    && rustup target add thumbv8m.main-none-eabi \
    && rustup target add thumbv8m.main-none-eabihf \
    && cargo install svd2rust

# RUN chmod -R a+rw $RUSTUP_HOME $CARGO_HOME;

WORKDIR /workspace

CMD [ "/bin/bash" ]
