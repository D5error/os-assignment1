#include "server.h"


// 定义命名管道的名称
const char *pipe_name = "22354191";


int main(int argc, char *argv[]) {
    // 检查命令行参数
    if (argc != 2) {
        fprintf(stderr, "Usage: %s lambda_s\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    // 读取控制参数
    lambda_s = atof(argv[1]);

    // 初始化信号量和互斥锁
    sem_init(&empty, 0, N_SLOTS);
    sem_init(&full, 0, 0);
    pthread_mutex_init(&mutex, NULL);

    // 创建消费者线程
    printf("创建%d个消费者线程\n", N_CONSUMERS);
    pthread_t consumers[N_CONSUMERS];
    int consumer_ids[N_CONSUMERS];
    for (int i = 0; i < N_CONSUMERS; i++) {
        consumer_ids[i] = i + 1;
        pthread_create(&consumers[i], NULL, consumer, consumer_ids + i);
    }

    // 创建管道线程
    printf("命名管道: %s\n", pipe_name);
    pthread_t pipe_thread;
    pthread_create(&pipe_thread, NULL, fifo_pipe, (void *)pipe_name);

    // 等待线程结束
    for (int i = 0; i < N_CONSUMERS; i++) {
        pthread_join(consumers[i], NULL);
    }
    pthread_join(pipe_thread, NULL);
    printf("所有线程结束\n");

    return 0;
}