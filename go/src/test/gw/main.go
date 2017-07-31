package main

import (
	"github.com/garyburd/redigo/redis"
	"github.com/go-pg/pg"
	"github.com/gramework/gramework"
	// _ "github.com/lib/pq"
	"fmt"
	"github.com/valyala/fasthttp"
	"os"
	"runtime"
	"time"
)

func Reverse(s string) string {
	runes := []rune(s)
	for i, j := 0, len(runes)-1; i < j; i, j = i+1, j-1 {
		runes[i], runes[j] = runes[j], runes[i]
	}
	return string(runes)
}

type Item struct {
	Id    int
	Title string
}

func SetupRedis() *redis.Pool {
	return redis.NewPool(func() (redis.Conn, error) {
		c, err := redis.Dial("unix", "/tmp/redis.sock")

		if err != nil {
			panic("error")
		}

		return c, err
	}, 10)
}

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())

	redisPool := SetupRedis()
	redisPool.Wait = true
	redisPool.IdleTimeout = 240 * time.Second
	redisPool.MaxActive = 10
	defer redisPool.Close()

	db := pg.Connect(&pg.Options{
		Network:     "unix",
		Addr:        "/tmp/.s.PGSQL.5432",
		User:        "foo",
		Database:    "testdb",
		PoolSize:    10,
		IdleTimeout: 3600 * time.Second,
	})

	/*
		db.OnQueryProcessed(func(event *pg.QueryProcessedEvent) {
			query, err := event.FormattedQuery()
			if err != nil {
				panic(err)
			}

			fmt.Printf("%s %s\n", time.Since(event.StartTime), query)
		})
	*/

	app := gramework.New()

	app.GET("/json", func(c *gramework.Context) {
		c.JSON(map[string]string{
			"hello": "world",
		})
	})

	app.GET("/get", func(c *gramework.Context) {
		rds := redisPool.Get()
		defer rds.Close()

		value, _ := redis.String(rds.Do("GET", "mydata"))

		c.WriteString(value)
	})

	app.GET("/set", func(c *gramework.Context) {
		rds := redisPool.Get()
		defer rds.Close()

		value, _ := redis.String(rds.Do("SET", "uid", c.Request.Header.Peek("X-Request-Id")))

		c.WriteString(value)
	})

	app.GET("/select", func(c *gramework.Context) {
		item := Item{Id: 1}
		err := db.Select(&item)
		if err != nil {
			fmt.Println(err)
		}

		c.JSON(map[string]interface{}{
			"id":    item.Id,
			"title": item.Title,
		})
	})

	app.GET("/update", func(c *gramework.Context) {
		item := Item{Id: 1}
		err := db.Select(&item)
		if err != nil {
			fmt.Println(err)
		}

		item.Title = Reverse(item.Title)
		err = db.Update(&item)

		if err != nil {
			fmt.Println(err)
		}

		c.JSON(map[string]interface{}{
			"id":    item.Id,
			"title": item.Title,
		})
	})

	fmt.Println("start")

	port, is_port := os.LookupEnv("PORT")
	if is_port {
		app.ListenAndServe(port)
	} else {
		s := fasthttp.Server{
			Handler: app.Handler(),
		}
		s.ListenAndServeUNIX("/tmp/test.sock", os.ModeSocket|0777)
	}
}
