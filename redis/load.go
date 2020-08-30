package main

import (
	"context"
	"fmt"
	"os"
	"strconv"

	"github.com/go-redis/redis/v8"
)

func Client(addr string) *redis.Client {
	return redis.NewClient(&redis.Options{
		Addr:     addr,
		Password: "", // no password set
		DB:       0,  // use default DB
	})
}

func main() {
	var err error
	ctx := context.TODO()

	var idx int
	if len(os.Args) > 1 {
		idx, err = strconv.Atoi(os.Args[1])
		if err != nil {
			panic(err)
		}
	}

	num := 10000
	if len(os.Args) > 2 {
		num, err = strconv.Atoi(os.Args[2])
		if err != nil {
			panic(err)
		}
	}
	rdb := Client(fmt.Sprintf("localhost:%d", 6379+idx))
	for i := 0; i < num; i++ {
		err := rdb.Set(ctx, fmt.Sprintf("%d", i), fmt.Sprintf("%d", i), 0).Err()
		if err != nil {
			fmt.Printf("error: %s\n", err.Error())
		}
		fmt.Println(i)
	}
}
