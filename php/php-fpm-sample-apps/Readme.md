start container

```bash
docker build -t php-fpm:latest .
docker-compose --env-file env/.env.dynamic up -d
```
tunning

```bash
net.nf_conntrack_max = 131072
net.core.somaxconn = 131072
kernel.msgmnb = 131072
kernel.msgmax = 131072
fs.file-max = 131072
```


variables

- `PHPFPM_CONTAINER_MEM_LIMIT`: sets a memory limit to the php-fpm container. This parameter allows you to see the behavior of the container when memory is allocated in different ways.

- `PM_STRATEGY`: Set the process manager strategy to static, dynamic or ondemand.
- `PM_MAX_CHILDREN`: Defines the maximum number of worker processes that can be created.
- `PM_MAX_REQUESTS`: Number of total requests a single worker can process after which it's restarted.
- `PM_REQUEST_TERMINATE_TIMEOUT`: Max execution time in seconds before php-fpm terminates a worker.
- `PM_CHILDREN_MEMORY_LIMIT`: Determines the maximum amount of memory a worker can allocate

- `PM_START_SERVERS`: Determines the initial number of worker processes to be created at startup.
- `PM_MIN_SPARE_SERVERS`: Sets the minimum number of idle worker processes that should be always maintained. If the number of idle workers falls below this value, PHP-FPM will create additional processes.
- `PM_MAX_SPARE_SERVERS`: Specifies the maximum number of idle worker processes allowed. If the number of idle workers exceeds this value, PHP-FPM will terminate excess processes.
- `PM_PROCESS_IDLE_TIMEOUT`: Indicates the duration after which idle worker processes will be terminated.

- `PHP_MEM_USED_IN_MB`: Sets a fixed amount of memory used by your php script.
- `PHP_EXECUTION_TIME_IN_SECONDS`: Sets a fixed amount of seconds your php script takes to be processed.
