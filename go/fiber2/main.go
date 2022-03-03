package main

import (
	"context"
	"net"
	"fmt"
	"time"

	"github.com/go-redis/redis/v8"
	"github.com/gofiber/fiber/v2"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type Item struct {
	ID    uint
	Title string
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

	dsn := "host=/tmp dbname=testdb sslmode=disable"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		// SkipDefaultTransaction: true,
		// PrepareStmt: true,
		Logger: logger.Default.LogMode(logger.Silent),
	})
	if err != nil {
		panic("failed to connect database")
	}

	sqlDB, err := db.DB()
	if err != nil {
		panic("failed to connect database")
	}
	sqlDB.SetMaxIdleConns(30)
	sqlDB.SetMaxOpenConns(30)
	sqlDB.SetConnMaxLifetime(time.Hour)

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
		var item Item
		db.Take(&item, 1)
		return c.JSON(fiber.Map{
			"id":    item.ID,
			"title": item.Title,
		})
	})

	app.Get("/update", func(c *fiber.Ctx) error {
		var item Item
		db.Take(&item, 1)
		item.Title = Reverse(item.Title)
		db.Save(&item)
		return c.JSON(fiber.Map{
			"id":    item.ID,
			"title": item.Title,
		})
	})

	fmt.Println("start fiber + gorm ...")

	ln, err := net.Listen("unix", "/tmp/test.sock")
	if err != nil {
		panic("error")
	}

	app.Listener(ln)
}
