#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>
#include <stdlib.h>
#include<fcntl.h>
#include<sys/stat.h>
#include <math.h>


#define MIN_CONSUMERS 3
#define MAX_CONSUMERS 10
#define N_SLOTS 20
#define SLOTS_LOWER_THREAD 5  
#define SLOTS_UPPER_THREAD 15

// 线程动态增减的时间间隔
#define CHECK_SECONDS 0.6

// 控制参数
double lambda_s;


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
int slots_count;


// 同步工具
sem_t empty;    // 空槽位信号量(初始为 N_SLOTS)
sem_t full;     // 满槽位信号量(初始为 0)
pthread_mutex_t mutex;  // 互斥锁，保护缓冲区访问


// 记录消费者的信息
pthread_t consumers[MAX_CONSUMERS];
int consumer_ids[MAX_CONSUMERS];
int running_consumers_num;


// 初始化
void init();

// 消费者
void *consumer(void *arg);

// 动态控制消费者线程
void *consumer_controller();

// 管道
void *fifo_pipe(void *arg);