package main

import (
	"fmt"
	"github.com/buaazp/fasthttprouter"
	"github.com/fasthttp-contrib/render"
	"github.com/garyburd/redigo/redis"
	"github.com/go-xorm/core"
	"github.com/go-xorm/xorm"
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

	router := fasthttprouter.New()
	r := render.New()

	router.GET("/json", func(ctx *fasthttp.RequestCtx) {
		r.JSON(ctx, fasthttp.StatusOK, map[string]string{
			"hello": "world",
		})
	})

	router.GET("/get", func(ctx *fasthttp.RequestCtx) {
		rds := redisPool.Get()
		defer rds.Close()

		value, _ := redis.String(rds.Do("GET", "mydata"))

		r.Text(ctx, fasthttp.StatusOK, value)
	})

	router.GET("/set", func(ctx *fasthttp.RequestCtx) {
		rds := redisPool.Get()
		defer rds.Close()

		value, _ := redis.String(rds.Do("SET", "uid", ctx.Request.Header.Peek("X-Request-Id")))

		r.Text(ctx, fasthttp.StatusOK, value)
	})

	router.GET("/select", func(ctx *fasthttp.RequestCtx) {
		item := Item{}
		has, _ := engine.Where("id = ?", 1).Get(&item)
		if has {
			r.JSON(ctx, fasthttp.StatusOK, map[string]interface{}{
				"id":    item.Id,
				"title": item.Title,
			})
		}
	})

	router.GET("/update", func(ctx *fasthttp.RequestCtx) {
		item := Item{}
		has, _ := engine.Where("id = ?", 1).Get(&item)
		if has {
			item.Title = Reverse(item.Title)
			_, err := engine.Id(1).Update(&item)

			if err != nil {
				fmt.Println(err)
			} else {
				r.JSON(ctx, fasthttp.StatusOK, map[string]interface{}{
					"id":    item.Id,
					"title": item.Title,
				})
			}
		}
	})

	s := fasthttp.Server{
		Handler: router.Handler,
	}
	port, is_port := os.LookupEnv("PORT")
	if is_port {
		s.ListenAndServe(port)
	} else {
		s.ListenAndServeUNIX("/tmp/test.sock", os.ModeSocket|0777)
	}
}
