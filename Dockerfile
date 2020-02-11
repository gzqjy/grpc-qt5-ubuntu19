FROM ubuntu:disco
MAINTAINER gongzhq "104704656@qq.com"

RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
#RUN echo 'deb http://mirrors.ustc.edu.cn/debian experimental main' > /etc/apt/sources.list.d/experimental.list
RUN apt-get update

RUN apt-get install -y git apt-utils libgrpc++1
RUN apt-get install -y protobuf-compiler-grpc
RUN apt-get install -y fonts-wqy-zenhei
RUN apt-get install -y locales debootstrap
RUN apt-get install -y gcc-8-mips64el-linux-gnuabi64 gcc-8-aarch64-linux-gnu
RUN apt-get install -y qt5-default
RUN apt-get install -y qt5-qmake-bin
RUN apt-get install -y qt5-qmake

ENV GOPROXY https://goproxy.cn
ENV GO111MODULE on
ENV GO go1.13.4.linux-amd64.tar.gz
ENV PATH ${PATH}:/usr/local/go/bin:/root/go/bin

ADD https://dl.google.com/go/go1.13.7.linux-amd64.tar.gz . 
RUN tar -zxvf go1.13.7.linux-amd64.tar.gz -C /usr/local
#ADD go1.13.7.linux-amd64.tar.gz /usr/local

RUN go get -u github.com/golang/protobuf/proto
RUN go get -u github.com/golang/protobuf/protoc-gen-go
RUN go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway
RUN go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger

RUN apt-get install -y locales && sed -i '/^#.* zh_CN.UTF-8 /s/^#//' /etc/locale.gen && locale-gen
ENV LANG zh_CN.UTF-8

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

WORKDIR /root
RUN debootstrap --arch=mips64el bullseye grpc-qt5-mips64el-debian11 http://mirrors.tuna.tsinghua.edu.cn/debian
RUN debootstrap --arch=arm64 bullseye grpc-qt5-arm64-debian11 http://mirrors.tuna.tsinghua.edu.cn/debian

#ADD grpc-qt5-mips64el-debian11.tar.gz /root
#ADD grpc-qt5-arm64-debian11.tar.gz /root

COPY set_grpc_env.sh /root/grpc-qt5-mips64el-debian11/
RUN chmod 755 /root/grpc-qt5-mips64el-debian11/set_grpc_env.sh
RUN chroot /root/grpc-qt5-mips64el-debian11/ /bin/bash -c /set_grpc_env.sh

COPY set_grpc_env.sh /root/grpc-qt5-arm64-debian11/
RUN chmod +x /root/grpc-qt5-arm64-debian11/set_grpc_env.sh
RUN chroot /root/grpc-qt5-arm64-debian11/ /bin/bash -c /set_grpc_env.sh

ADD linuxdeploy-amd64.tar.gz /opt
ADD linuxdeploy-arm64.tar.gz /root/grpc-qt5-arm64-debian11/opt
ADD linuxdeploy-mips64el.tar.gz /root/grpc-qt5-mips64el-debian11/opt

#COPY *.deb /root/
#docker build -t grpc_qt5 .
#https://mirrors.ustc.edu.cn/debian/pool/main/g/grpc/
#https://github.com/linuxdeploy/linuxdeploy