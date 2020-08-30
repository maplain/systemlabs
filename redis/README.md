# Prerequisites

1. Docker: Follow [the official documentation](https://docs.docker.com/get-docker/) to download Docker.

# Cheatsheet

[Cheatsheet](https://hackmd.io/@maplainfly/rkO-W_PXv)

# Labs

Note: Each lab is independent. But within each lab, instructions could depend on
previous instructions.

## Lab 1: Basic commands

```bash
source docker-utils.sh

start 0
connect 0
redis-cli

KEYS *

# Feel free to try any command in the above Cheetsheet

# After you finish your experiment
kill 0
```

## Lab 2: Persistence

### AOF(Append Only File)
```bash
source docker-utils.sh
start 0

# In your Terminal 1
CONFIG SET appendonly yes

# In your Terminal 2
connect 0 'tail -f appendonly.aof'

# In your Terminal 1
SET 1 2
SET 2 3
GET 1
GET 2
DEL 1 

# Observe the output in your second terminal

# Use the following command to tune the fsync pace
CONFIG set appendfsync no
CONFIG set appendfsync everysec
CONFIG set appendfsync always

# In your Terminal 2
ls -al appendonly.aof
# Check the file size

# In your Terminal 1
BGREWRITEAOF

# In your Terminal 2
ls -al appendonly.aof

```

### RDB(Redis Database Backup file)
```bash
# In your Terminal 2
connect 0
ls -al

# In your Terminal 1
connect 0
redis-cli
SAVE

# In your Terminal 2
ls -al
# Notice there is a new file called "dump.rdb"
cat dump.rdb # show the content which might contains unprintable characters
tail -f dump.rdb # watch this file

# In your Terminal 1
SET 1 2
SET 2 3
SET 3 4
DEL 1
DEL 2
SAVE

# In your Terminal 2
# Notice there is nothing changed
# hit `ctrl+c` then run `tail -f dump.rdb` again
# Notice there is something new added into the file
# Why couldn't you see the change in the first `tail -f dump.rdb`?

# Now run this command
ls -i dump.rdb

# In your Terminal 1
SET 5 1
SET 3 9
SAVE

# In your Terminal 2
ls -i dump.rdb

# What happened? What does it mean? 

# Cleanup after you finished everything
kill 0
```

## Lab 3: Replication

```bash
source docker-utils.sh
start 0

# In your Terminal 1
connect 0
redis-cli

# In your Terminal 2
start 1 redis-server --replicaof $(ip 0) 6379
connect 1
redis-cli

# In your Terminal 1
SET 1 2
# In your Terminal 2
GET 1

# In your Terminal 1
# Check current instance replication status
info replication

# In your Terminal 2
# Check the current instance replication status
info replication
# Write down the master_host, master_replid, master_repl_offset

# In your Terminal 2
exit # exit redis cli

redis-cli -h [MASTER_HOST_IP] # connect to the master redis instance

# After everything is done, remove these two redis instances
kill 0
kill 1
```

### Partial/Full resynchronization
```bash
# In your Terminal 1
run 0 # Start the master redis instance in the foreground so we can see the logs

# Inject some workload into the master
go run load.go 0 3000

# In your Terminal 2
start 1 redis-server --replicaof $(ip 0) 6379 # Start the replica in the foreground

# Read the logs in the master and the replica

# In your Terminal 3
ip 0 # write down the master instance ip
ip 1 # write down the replica instance ip

connect 0
redis-cli -h [MASTER_INSTANCE_IP]
PSYNC [MASTER_REPLID] 1000
# Read the log in the master instance then ctrl + c
redis-cli -h [REPLICA_INSTANCE_IP]
PSYNC [MASTER_REPLID] 1000
# Read the log in the replica instance then ctrl + c

# hit ctrl+c to exit two redis instances
```

### See the replication protocol on wire
```bash
start 0

connect 0
apt update 
apt install -y iproute2 tcpdump
tcpdump

# In your terminal 2
start 1 redis-server --replicaof $(ip 0) 6379

# In your terminal 3
connect 0
redis-cli
SET 1 2

# Observe the tcpdump logs, what happened there?
exit
go run load.go 0 100
```

## Lab 4 High Availability

### Master failover
```bash
source docker-utils.sh

# Run three Redis instances in the foreground
# In your Terminal 1
run 0
# In your Terminal 2
run 1 redis-server --replicaof $(ip 0) 6379
# In your Terminal 3
run 2 redis-server --replicaof $(ip 1) 6379

# Run three Redis sentinels in the foreground
# In your Terminal 4
connect 0
redis-sentinel sentinel-0.conf
# In your Terminal 5
connect 1
redis-sentinel sentinel-1.conf
# In your Terminal 6
connect 2
redis-sentinel sentinel-2.conf

# Take a moment to read the logs

# Let's simulate a master failure

# In your Terminal 7
connect 0
redis-cli
DEBUG sleep 100

# Pay attention to the logs in the sentinel

# After the failover happens, check the other two Redis instances replica status
using command we showed before

# After the old master comes back, check its replica status

# Connect to the Sentinel
redis-cli -h [host_ip] -p 26379
SENTINEL masters
SENTINEL master [master name]
SENTINEL replicas [master name]

# PUB/SUB
# You can subscribe to channels for HA-related events
```

### Homework 1
1. Subscribe to +sdown messages

## Lab 5 Sharding
```bash

run 0 redis-server cluster-0.conf
run 1 redis-server cluster-1.conf
run 2 redis-server cluster-2.conf
start 3 redis-server cluster-3.conf
start 4 redis-server cluster-4.conf
start 5 redis-server cluster-5.conf

connect 0
# Create the cluster
redis-cli --cluster create 172.17.0.3:6379 172.17.0.4:6379 172.17.0.5:6379 172.17.0.6:6379 172.17.0.7:6379 172.17.0.8:6379 --cluster-replicas 1

# Reshard
redis-cli --cluster reshard [ip]

# Check node status
redis-cli cluster nodes

# Add a node
redis-cli --cluster add-node 172.17.0.9:6379 172.17.0.3:6379
```

### Homework 2
1. Test the failover in Cluster mode
