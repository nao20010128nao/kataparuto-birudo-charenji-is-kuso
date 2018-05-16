FROM ubuntu:xenial as catapult

RUN apt-get update && apt-get -y install \
      cmake git make automake libboost-dev libzmq-dev gcc g++ \
      librocksdb-dev libbson-dev

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 && \
    echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list && \
    apt-get update && apt-get -y install \
      mongodb-org

RUN mkdir -p /tmp/mongocxx && \
    cd /tmp/mongocxx && \
    git clone https://github.com/mongodb/mongo-cxx-driver drv -b releases/stable --depth=1 && \
    cd drv && \
    git checkout r3.2.0 && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local . && \
    make && make install && \
    cd / && rm -rf /tmp/mongocxx

RUN mkdir -p /tmp/gtest && \
    cd /tmp/gtest && \
    git clone https://github.com/google/googletest gt && \
    cd gt && \
    git checkout release-1.8.0 && \
    cmake CMakeLists.txt && \
    make && make install && \
    cd / && rm -rf /tmp/gtest

ENV PYTHON_EXECUTABLE=/usr/bin/python \
    BOOST_ROOT=/usr/bin \
    GTEST_ROOT=/usr/bin \
    LIBBSONCXX_DIR=/usr/bin \
    LIBMONGOCXX_DIR=/usr/bin \
    ZeroMQ_DIR=/usr/bin \
    cppzmq_DIR=/usr/bin \
    ROCKSDB_ROOT_DIR=/usr/bin

RUN mkdir -p /tmp/catapult && \
    cd /tmp/catapult && \
    git clone https://github.com/nemtech/catapult-server main --branch releases/stable --depth 1 && \
    cd main && \
    cmake -DCMAKE_BUILD_TYPE=RelWithDebugInfo .. && \
    make publish && make && \
    make install && \
    cd / && rm -rf /tmp/catapult
