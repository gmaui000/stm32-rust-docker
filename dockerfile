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
    locales vim net-tools sudo \
    git curl build-essential cmake \
    openocd gdb-multiarch libfuse2 stlink-tools libssl-dev pkg-config \
    libudev-dev libusb-dev libusb-1.0 usbutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Create non-root user stm32er with UID and GID 1000
RUN groupadd -r -g 1000 stm32er && useradd -r -u 1000 -g stm32er -m -s /bin/bash stm32er \
    && echo 'stm32er ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/stm32er \
    && chmod 0440 /etc/sudoers.d/stm32er

# Switch to stm32er user for Rust installation
USER stm32er
WORKDIR /home/stm32er

# Set environment variables for stm32er user
ENV CARGO_HOME=/home/stm32er/.cargo
ENV RUSTUP_HOME=/home/stm32er/.rustup
ENV PATH=$CARGO_HOME/bin:$RUSTUP_HOME/bin:$PATH

# add proxy
ENV http_proxy=http://192.168.31.164:7897
ENV https_proxy=http://192.168.31.164:7897

# Install Rust toolchain as stm32er user
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Copy config.yaml to stm32er's cargo directory
COPY --chown=stm32er:stm32er ./config.yaml ${CARGO_HOME}/cargo/

# Install Rust tools and components as stm32er user
RUN cargo install cargo-binutils \
    && cargo install flip-link \
    && cargo install probe-rs-tools --locked \
    && cargo install cargo-generate \
    && cargo install cargo-bloat \
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

# Create workspace directory and set permissions
USER root
RUN mkdir -p /workspace && chown stm32er:stm32er /workspace

# Switch back to stm32er user for runtime
USER stm32er
WORKDIR /workspace

CMD ["bash", "-c", "while true; do sleep 10; done"]
