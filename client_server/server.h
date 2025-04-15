#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>
#include <stdlib.h>
#include<fcntl.h>
#include<sys/stat.h>
#include <math.h>


#define N_CONSUMERS 3
#define N_SLOTS 20

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
int in = 0;
int out = 0;


// 同步工具
sem_t empty;    // 空槽位信号量(初始为 N_SLOTS)
sem_t full;     // 满槽位信号量(初始为 0)
pthread_mutex_t mutex;  // 互斥锁，保护缓冲区访问


// 消费者
void *consumer(void *arg) {
    pid_t pid = getpid();
    int tid = *(int *)arg;

    while (1) {
        // 等待满槽位
        sem_wait(&full);

        // 从缓冲区取出数据
        pthread_mutex_lock(&mutex);
        Msg msg = slots[out];
        out = (out + 1) % N_SLOTS;
        printf("进程: %d, 线程: %d, 处理数据: {进程=%d, 线程=%d , 数据=%d}\n", pid, tid, msg.process_id, msg.thread_id, msg.data);
        pthread_mutex_unlock(&mutex);

        // 添加空槽位
        sem_post(&empty);

        // 负指数分布延迟
        double u = (double)rand() / RAND_MAX; // 均匀分布随机数 U ∈ [0,1)
        double delay = lambda_s == 0 ? 0 : -log(1 - u) / lambda_s;
        printf("delay %f秒\n", delay);
        sleep(delay);
    }
}

// 管道
void *fifo_pipe(void *arg) {
    char *pip_name = (char *)arg;
    
    // 创建管道
    mkfifo(pip_name, 0666);
    
    // 打开管道
    int fd = open(pip_name,O_RDONLY);
    
    while (1) {
        // 从管道中读取消息
        Msg msg;
        read(fd, &msg, sizeof(Msg));
        
        // 等待空槽位
        sem_wait(&empty);

        // 数据放入缓冲区
        pthread_mutex_lock(&mutex);
        slots[in] = msg;
        in = (in + 1) % N_SLOTS;
        pthread_mutex_unlock(&mutex);

        // 添加满槽位
        sem_post(&full);
    }
}