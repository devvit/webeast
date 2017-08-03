package main

import (
	"fmt"
	"github.com/fasthttp-contrib/render"
	"github.com/go-pg/pg"
	"github.com/go-redis/redis"
	"github.com/qiangxue/fasthttp-routing"
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

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())

	rds := redis.NewClient(&redis.Options{
		Network:  "unix",
		Addr:     "/tmp/redis.sock",
		PoolSize: 10,
	})

	db := pg.Connect(&pg.Options{
		Network:     "unix",
		Addr:        "/tmp/.s.PGSQL.5432",
		User:        os.Getenv("USER"),
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

	router := routing.New()
	r := render.New()

	router.Get("/json", func(ctx *routing.Context) error {
		r.JSON(ctx.RequestCtx, fasthttp.StatusOK, map[string]string{
			"hello": "world",
		})

		return nil
	})

	router.Get("/get", func(ctx *routing.Context) error {
		value, _ := rds.Get("mydata").Result()

		r.Text(ctx.RequestCtx, fasthttp.StatusOK, value)

		return nil
	})

	router.Get("/set", func(ctx *routing.Context) error {
		value, _ := rds.Set("uid", ctx.RequestCtx.Request.Header.Peek("X-Request-Id"), 0).Result()

		r.Text(ctx.RequestCtx, fasthttp.StatusOK, value)

		return nil
	})

	router.Get("/select", func(ctx *routing.Context) error {
		item := Item{Id: 1}
		err := db.Select(&item)
		if err != nil {
			fmt.Println(err)
		}

		r.JSON(ctx.RequestCtx, fasthttp.StatusOK, map[string]interface{}{
			"id":    item.Id,
			"title": item.Title,
		})

		return nil
	})

	router.Get("/update", func(ctx *routing.Context) error {
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

		r.JSON(ctx.RequestCtx, fasthttp.StatusOK, map[string]interface{}{
			"id":    item.Id,
			"title": item.Title,
		})

		return nil
	})

	fmt.Println("start")

	s := fasthttp.Server{
		Handler: router.HandleRequest,
	}
	port, is_port := os.LookupEnv("PORT")
	if is_port {
		s.ListenAndServe(port)
	} else {
		s.ListenAndServeUNIX("/tmp/test.sock", os.ModeSocket|0777)
	}
}
