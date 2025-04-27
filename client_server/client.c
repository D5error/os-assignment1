#include "client.h"

// 定义命名管道的名称
#define PIPE_NAME "22354191"

int main(int argc, char *argv[]) {
    // 读取控制参数
    if (argc != 2) {
        fprintf(stderr, "Usage: %s lambda_c\n", argv[0]);
        exit(EXIT_FAILURE);
    }
    lambda_c = atof(argv[1]);

    // 初始化
    init();

    // 创建管道线程
    printf("命名管道: %s\n", PIPE_NAME);
    pthread_t pipe_thread;
    pthread_create(&pipe_thread, NULL, fifo_pipe, PIPE_NAME);

    // 创建生产者线程
    printf("创建%d个生产者线程\n", N_PRODUCERS);
    pthread_t producers[N_PRODUCERS];
    int producer_ids[N_PRODUCERS];
    for (int i = 0; i < N_PRODUCERS; i++) {
        producer_ids[i] = i + 1;
        pthread_create(&producers[i], NULL, producer, producer_ids + i);
    }

    // 等待线程结束
    for (int i = 0; i < N_PRODUCERS; i++) {
        pthread_join(producers[i], NULL);
    }
    pthread_join(pipe_thread, NULL);
    printf("所有线程结束\n");

    return 0;
}


void init() {
    in = 0;
    out = 0;
    sem_init(&empty, 0, N_SLOTS);
    sem_init(&full, 0, 0);
    pthread_mutex_init(&mutex, NULL);

    // 避免每次运行都生成一样的随机数
    srand(time(NULL));
}

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
        double delay = lambda_c < 0 ? 0 : lambda_c * exp(-lambda_c * u);
        printf("delay %f秒\n", delay);
        usleep(delay * 1000000);
    }
}

void *fifo_pipe(void *arg) {
    // 打开管道
    char *pip_name = (char *)arg;
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