## Using GDB
1. 
make qemu-gdb

2. 
gdb-multiarch user/sleep.o -ex "set arch riscv:rv64" -ex "target remote :25000" 
gdb-multiarch kernel/kernel -ex "set arch riscv:rv64" -ex "target remote :25000" 
b syscall
c
layout src
backtrace
n
p /x *p
b *0x80001c82
layout asm