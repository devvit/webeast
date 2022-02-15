package main

import (
  "fmt"
  "time"
  "context"

  "gorm.io/driver/postgres"
  "gorm.io/gorm"
  "gorm.io/gorm/logger"
  "github.com/gin-gonic/gin"
  "github.com/go-redis/redis/v8"
)

type Item struct {
  ID uint
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
  // runtime.GOMAXPROCS(runtime.NumCPU())

  rds := redis.NewClient(&redis.Options{
    Network:  "unix",
    Addr:     "/tmp/redis.sock",
    PoolSize: 30,
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
    var item Item
    db.Take(&item, 1)
    c.JSON(200, gin.H{
      "id": item.ID,
      "title": item.Title,
    })
  })

  r.GET("/update", func(c *gin.Context) {
    var item Item
    db.Take(&item, 1)
    item.Title = Reverse(item.Title)
    db.Save(&item)
    c.JSON(200, gin.H{
      "id": item.ID,
      "title": item.Title,
    })
  })

  fmt.Println("start gorm ...")
  r.RunUnix("/tmp/test.sock")
}
