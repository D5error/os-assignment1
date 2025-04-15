#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <math.h>


#define N_PRODUCERS 1
#define N_SLOTS 200


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
int in = 0;
int out = 0;


// 同步工具
sem_t empty;    // 空槽位信号量(初始为 N_SLOTS)
sem_t full;     // 满槽位信号量(初始为 0)
pthread_mutex_t mutex;  // 互斥锁，保护缓冲区访问


// 生产者
void *producer(void *arg) {
    Msg msg;
    msg.process_id = getpid();
    msg.thread_id = *(int *)arg;
    
    while (1) {
        // 生产数据
        msg.data = rand() % 100;
    
        // 等待空槽位
        sem_wait(&empty);
        
        // 数据并放入缓冲区
        pthread_mutex_lock(&mutex);
        slots[in] = msg;
        in = (in + 1) % N_SLOTS;
        printf("进程: %d, 线程: %d, 产生数据: %d\n", msg.process_id, msg.thread_id, msg.data);
        pthread_mutex_unlock(&mutex);
    
        // 增加满槽位
        sem_post(&full);

        // 负指数分布延迟
        double u = (double)rand() / RAND_MAX; // 均匀分布随机数 U ∈ [0,1)
        double delay = lambda_c == 0 ? 0 : -log(1 - u) / lambda_c;
        printf("delay %f秒\n", delay);
        sleep(delay);
    }
}


// 管道
void *fifo_pipe(void *arg) {
    char *pip_name = (char *)arg;

    // 打开管道
    int fd = open(pip_name,O_WRONLY);

    while (1) {
        // 等待满槽位
        sem_wait(&full);

        // 从缓冲区取出数据
        pthread_mutex_lock(&mutex);
        Msg msg = slots[out];
        out = (out + 1) % N_SLOTS;
        pthread_mutex_unlock(&mutex);

        // 添加空槽位
        sem_post(&empty);

        // 写入管道
        write(fd, &msg, sizeof(Msg));

    }
    // 关闭管道
    close(fd);
}