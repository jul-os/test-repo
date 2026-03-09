# to run 
# docker build -f Dockerfile.app -t testproj-app .
# timeout 5 docker run --rm testproj-app
FROM gcc:latest

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://github.com/Kitware/CMake/releases/download/v3.24.2/cmake-3.24.2-linux-x86_64.tar.gz -O /tmp/cmake.tar.gz && \
    tar -xzf /tmp/cmake.tar.gz -C /opt && \
    ln -s /opt/cmake-3.24.2-linux-x86_64/bin/cmake /usr/local/bin/cmake && \
    ln -s /opt/cmake-3.24.2-linux-x86_64/bin/ctest /usr/local/bin/ctest && \
    rm /tmp/cmake.tar.gz

RUN git clone --depth 1 --branch v1.14.0 https://github.com/google/googletest.git /usr/src/googletest && \
    mkdir -p /usr/src/googletest/build && \
    cd /usr/src/googletest/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_GMOCK=OFF -DCMAKE_INSTALL_PREFIX=/usr/local && \
    make -j$(nproc) && \
    make install && \
    ldconfig

WORKDIR /app

COPY . .

RUN mkdir -p build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)

CMD ["./build/candle_tests"]