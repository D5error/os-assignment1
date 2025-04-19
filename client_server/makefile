# 定义编译器和编译选项
CC = gcc
CFLAGS = -lpthread -lm

# 定义要生成的可执行文件
TARGETS = client server

# 默认编译所有目标
all: $(TARGETS)

# 编译 client
client: client.c client.h
	$(CC) -o $@ $< $(CFLAGS)

# 编译 server
server: server.c server.h
	$(CC) -o $@ $< $(CFLAGS)

# 清理生成的可执行文件
clean:
	rm -f $(TARGETS)

# 声明伪目标（不生成实际文件）
.PHONY: all clean