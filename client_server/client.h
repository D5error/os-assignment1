#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <math.h>


#define N_PRODUCERS 3
#define N_SLOTS 20


// 控制参数
double lambda_c;

// 消息结构体
typedef struct {
    pid_t process_id;
    int thread_id;
    int data;
} Msg;


// 缓冲区
Msg slots[N_SLOTS];
int in;
int out;


// 同步工具
sem_t empty;    // 空槽位信号量(初始为 N_SLOTS)
sem_t full;     // 满槽位信号量(初始为 0)
pthread_mutex_t mutex;  // 互斥锁，保护缓冲区访问


// 初始化
void init();

// 生产者
void *producer(void *arg);

// 管道
void *fifo_pipe(void *arg);