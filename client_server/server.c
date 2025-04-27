#include "server.h"

// 定义命名管道的名称
const char *pipe_name = "22354191";

int main(int argc, char *argv[]) {
    // 读取控制参数
    if (argc != 2) {
        fprintf(stderr, "Usage: %s lambda_s\n", argv[0]);
        exit(EXIT_FAILURE);
    }
    lambda_s = atof(argv[1]);

    // 初始化
    init();
    
    // 创建管道线程
    printf("命名管道: %s\n", pipe_name);
    pthread_t pipe_thread;
    pthread_create(&pipe_thread, NULL, fifo_pipe, (void *)pipe_name);

    // 创建动态控制消费者数量的进程
    pthread_t controller;
    pthread_create(&controller, NULL, consumer_controller, NULL);

    // 等待线程结束
    for (int i = 0; i < running_consumers_num; i++) {
        pthread_join(consumers[i], NULL);
    }
    pthread_join(pipe_thread, NULL);
    printf("所有线程结束\n");

    return 0;
}

void *consumer_controller() {
    // 创建消费者线程
    printf("创建%d个消费者线程\n", MIN_CONSUMERS);
    for (int i = 0; i < MIN_CONSUMERS; i++) {
        consumer_ids[i] = i + 1;
        running_consumers_num++;
        pthread_create(&consumers[i], NULL, consumer, consumer_ids + i);
    }

    // 动态控制消费者数量
    while (1) {
        // 加锁
        pthread_mutex_lock(&mutex);

        // 缓冲区数量低于低阈值
        if (slots_count < SLOTS_LOWER_THRESHOLD && running_consumers_num > MIN_CONSUMERS) {
            running_consumers_num--;
            pthread_create(&consumers[running_consumers_num - 1], NULL, consumer, &running_consumers_num);
            printf("缓冲区数量小于%d, 减少1名消费者\n", SLOTS_LOWER_THRESHOLD);
        }
        
        // 缓冲区数量高于高阈值
        else if (slots_count > SLOTS_UPPER_THRESHOLD && running_consumers_num < MAX_CONSUMERS) {
            running_consumers_num++;
            pthread_create(&consumers[running_consumers_num - 1], NULL, consumer, &running_consumers_num);
            printf("缓冲区数量大于%d, 添加1名消费者\n", SLOTS_UPPER_THRESHOLD);
        }

        // 打印信息
        printf("缓冲区数量 = %d, 消费者数量 = %d\n", slots_count, running_consumers_num);

        // 解锁
        pthread_mutex_unlock(&mutex);

        // 每隔XX秒检查一次
        usleep(CHECK_SECONDS * 1000000);

    }
}

void init() {
    // 缓冲区
    in = 0;
    out = 0;
    slots_count = 0;
    sem_init(&empty, 0, N_SLOTS);
    sem_init(&full, 0, 0);
    pthread_mutex_init(&mutex, NULL);

    // 避免每次运行都生成一样的随机数
    srand(time(NULL));
}

void *consumer(void *arg) {
    pid_t pid = getpid();
    int tid = *(int *)arg;

    while (1) {
        // 等待满槽位
        sem_wait(&full);

        // 从缓冲区取出数据
        pthread_mutex_lock(&mutex);
        Msg msg = slots[out];
        slots_count--;
        out = (out + 1) % N_SLOTS;
        printf("进程: %d, 线程: %d, 处理数据: {进程=%d, 线程=%d , 数据=%d}\n", pid, tid, msg.process_id, msg.thread_id, msg.data);
        pthread_mutex_unlock(&mutex);

        // 添加空槽位
        sem_post(&empty);

        // 负指数分布延迟
        double u = (double)rand() / RAND_MAX; // 均匀分布随机数 U ∈ [0,1)
        double delay = lambda_s < 0 ? 0 : lambda_s * exp(-lambda_s * u);
        printf("delay %f秒\n", delay);
        usleep(delay * 1000000);
    }
}

void *fifo_pipe(void *arg) {
    // 创建管道
    char *pip_name = (char *)arg;
    mkfifo(pip_name, 0666);
    
    // 打开管道
    int fd = open(pip_name,O_RDONLY);
    
    Msg msg;
    while (1) {
        // 从管道中读取消息
        ssize_t bytes = read(fd, &msg, sizeof(Msg));
        
        // 检查客户端是否断开
        if (bytes == 0) {
            printf("客户端断开连接\n");
            sleep(1);
            continue;
        }

        // 等待空槽位
        sem_wait(&empty);

        // 数据放入缓冲区
        pthread_mutex_lock(&mutex);
        slots[in] = msg;
        slots_count++;
        in = (in + 1) % N_SLOTS;
        pthread_mutex_unlock(&mutex);

        // 添加满槽位
        sem_post(&full);
    }
}