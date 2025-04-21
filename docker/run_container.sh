# /bin/bash


# 删除容器
docker rm -f my-container

# 编译
docker build --network host -t os-assignment-1 .

# 运行容器
docker run \
    -v "$(pwd)/../client_server:/home/ubuntu/os-assignment-1/client_server" \
    -v "$(pwd)/../xv6-labs-2024:/home/ubuntu/os-assignment-1/xv6-labs-2024" \
    -w "/home/ubuntu/os-assignment-1" \
    -it os-assignment-1 bash

