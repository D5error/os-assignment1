#include "client.h"

// 定义命名管道的名称
#define PIPE_NAME "22354191"

int main(int argc, char *argv[]) {
    // 检查命令行参数
    if (argc != 2) {
        fprintf(stderr, "Usage: %s lambda_c\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    // 读取控制参数
    lambda_c = atof(argv[1]);

    // 初始化信号量和互斥锁
    sem_init(&empty, 0, N_SLOTS);
    sem_init(&full, 0, 0);
    pthread_mutex_init(&mutex, NULL);

    // 避免每次运行都生成一样的随机数
    srand(time(NULL));

    // 创建生产者线程
    printf("创建%d个生产者线程\n", N_PRODUCERS);
    pthread_t producers[N_PRODUCERS];
    int producer_ids[N_PRODUCERS];
    for (int i = 0; i < N_PRODUCERS; i++) {
        producer_ids[i] = i + 1;
        pthread_create(&producers[i], NULL, producer, producer_ids + i);
    }

    // 创建管道线程
    printf("命名管道: %s\n", PIPE_NAME);
    pthread_t pipe_thread;
    pthread_create(&pipe_thread, NULL, fifo_pipe, PIPE_NAME);

    // 等待线程结束
    for (int i = 0; i < N_PRODUCERS; i++) {
        pthread_join(producers[i], NULL);
    }
    pthread_join(pipe_thread, NULL);
    printf("所有线程结束\n");

    return 0;
}
