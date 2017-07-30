package main

import (
	"fmt"
	// "github.com/bradfitz/gomemcache/memcache"
	"github.com/garyburd/redigo/redis"
	"github.com/go-xorm/core"
	"github.com/go-xorm/xorm"
	"github.com/gramework/gramework"
	_ "github.com/lib/pq"
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
	Id    int    `xorm:"id pk"`
	Title string `xorm:"title"`
}

func (Item) TableName() string {
	return "items"
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

	engine, err := xorm.NewEngine("postgres", "host=/tmp dbname=testdb")
	if err != nil {
		return
	}

	engine.SetMapper(core.SameMapper{})
	engine.ShowSQL(false)
	engine.SetMaxOpenConns(10)
	engine.SetMaxIdleConns(10)

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
		item := Item{}
		has, _ := engine.Where("id = ?", 1).Get(&item)
		if has {
			c.JSON(map[string]interface{}{
				"id":    item.Id,
				"title": item.Title,
			})
		}
	})

	app.GET("/update", func(c *gramework.Context) {
		item := Item{}
		has, _ := engine.Where("id = ?", 1).Get(&item)
		if has {
			item.Title = Reverse(item.Title)
			_, err := engine.Id(1).Update(&item)

			if err != nil {
				fmt.Println(err)
			} else {
				c.JSON(map[string]interface{}{
					"id":    item.Id,
					"title": item.Title,
				})
			}
		}
	})

	port, is_port := os.LookupEnv("PORT")
	if is_port {
		app.ListenAndServe(port)
	} else {
		s := fasthttp.Server{
			Handler: app.Handler(),
		}
		s.ListenAndServeUNIX("/tmp/test.sock", os.ModeSocket | 0777)
	}
}
