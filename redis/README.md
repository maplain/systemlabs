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
```
