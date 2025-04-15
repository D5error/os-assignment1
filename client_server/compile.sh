# /bin/bash 
rm -f client
rm -f server
gcc -o client client.c -lpthread -lm
gcc -o server server.c -lpthread -lm