#!/bin/bash
apt-get install -y locales  
apt-get install -y locales && sed -i '/^#.* zh_CN.UTF-8 /s/^#//' /etc/locale.gen && locale-gen
export LANG=zh_CN.UTF-8
apt-get install -y tzdata
echo "Asia/Shanghai" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
apt-get install -y libgrpc++1 protobuf-compiler-grpc fonts-wqy-zenhei 
apt-get install -y qt5-default qt5-qmake-bin qt5-qmake
exit 0