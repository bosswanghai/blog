linux 环境开发

### 信号量
int sem_init(sem_t *sem, int pshared, unsigned int value);
- sem 信号量，在进程间和线程间共享情况不一样
- pshared 0 线程之间共享；1进程之间共享
- value 信号量初始值，sem_wait调用的时候减去该数值

int sem_wait(sem_t *sem); lock a semaphore
int sem_trywait(sem_t *sem);
int sem_timedwait(sem_t *sem, const struct timespec *abs_timeout);
以阻塞操作减去sem数值，如果sem>0则-1，如果=0则阻塞

int sem_post(sem_t *sem);unlock a semaphore
sem+1，同时解锁sem，其他的sem_wait收到后，会进行后续处理

int sem_destroy(sem_t *sem); destroy an unnamed semaphore
