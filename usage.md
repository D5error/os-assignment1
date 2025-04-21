## Using GDB
1. 
make qemu-gdb

2. 
gdb-multiarch kernel/kernel -ex "set arch riscv:rv64" -ex "target remote :25000" 
b syscall
c
layout src
backtrace
n
p /x *p