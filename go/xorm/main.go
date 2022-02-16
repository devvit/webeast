package main

import (
	"context"
	"fmt"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/go-redis/redis/v8"
	_ "github.com/lib/pq"
	"xorm.io/xorm"
	"xorm.io/xorm/names"
)

type Item struct {
	Id    int    `xorm:"id pk"`
	Title string `xorm:"title"`
}

func (Item) TableName() string {
	return "items"
}

func Reverse(s string) string {
	r := []rune(s)
	for i, j := 0, len(r)-1; i < len(r)/2; i, j = i+1, j-1 {
		r[i], r[j] = r[j], r[i]
	}
	return string(r)
}

var ctx = context.Background()

func main() {
	// runtime.GOMAXPROCS(runtime.NumCPU())

	rds := redis.NewClient(&redis.Options{
		Network:  "unix",
		Addr:     "/tmp/redis.sock",
		PoolSize: 10,
	})

	engine, err := xorm.NewEngine("postgres", "host=/tmp dbname=testdb")
	if err != nil {
		return
	}

	engine.SetMapper(names.SameMapper{})
	engine.ShowSQL(false)
	engine.SetMaxOpenConns(10)
	engine.SetMaxIdleConns(10)

	r := gin.New()

	r.GET("/json", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"hello": "world",
		})
	})

	r.GET("/get", func(c *gin.Context) {
		val, _ := rds.Get(ctx, "hello").Result()
		c.JSON(200, gin.H{
			"hello": val,
		})
	})

	r.GET("/select", func(c *gin.Context) {
		item := Item{}
		engine.Where("id = ?", 1).Get(&item)
		c.JSON(200, gin.H{
			"id":    item.Id,
			"title": item.Title,
		})
	})

	r.GET("/update", func(c *gin.Context) {
		item := Item{}
		engine.Where("id = ?", 1).Get(&item)
		item.Title = Reverse(item.Title)
		engine.ID(1).Update(&item)
		c.JSON(200, gin.H{
			"id":    item.Id,
			"title": item.Title,
		})
	})

	fmt.Println("start xorm ...")
	port, use_port := os.LookupEnv("PORT")
	if use_port {
		r.Run(port)
	} else {
		r.RunUnix("/tmp/test.sock")
	}
}
