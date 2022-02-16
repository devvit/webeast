package main

import (
	"context"
	"net"
	"fmt"

	"github.com/go-redis/redis/v8"
	"github.com/gofiber/fiber/v2"
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

	app := fiber.New(fiber.Config{
		// Prefork: true,
	})

	app.Get("/json", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"hello": "world",
		})
	})

	app.Get("/get", func(c *fiber.Ctx) error {
		val, _ := rds.Get(ctx, "hello").Result()
		return c.JSON(fiber.Map{
			"hello": val,
		})
	})

	app.Get("/select", func(c *fiber.Ctx) error {
		item := Item{}
		engine.Where("id = ?", 1).Get(&item)
		return c.JSON(fiber.Map{
			"id":    item.Id,
			"title": item.Title,
		})
	})

	app.Get("/update", func(c *fiber.Ctx) error {
		item := Item{}
		engine.Where("id = ?", 1).Get(&item)
		item.Title = Reverse(item.Title)
		engine.ID(1).Update(&item)
		return c.JSON(fiber.Map{
			"id":    item.Id,
			"title": item.Title,
		})
	})

	fmt.Println("start fiber ...")

	ln, err := net.Listen("unix", "/tmp/test.sock")
	if err != nil {
		panic("error")
	}

	app.Listener(ln)
}
