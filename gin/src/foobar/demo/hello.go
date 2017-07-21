package main

import (
	"fmt"
	// "github.com/bradfitz/gomemcache/memcache"
	"github.com/garyburd/redigo/redis"
	"github.com/gin-gonic/gin"
	"github.com/go-xorm/core"
	"github.com/go-xorm/xorm"
	_ "github.com/lib/pq"
	eztemplate "github.com/michelloworld/ez-gin-template"
	"github.com/pangudashu/memcache"
	"github.com/parnurzeal/gorequest"
	"net/http"
	"runtime"
	"time"
	"unicode/utf8"
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
		c, err := redis.Dial("tcp", ":6379")

		if err != nil {
			panic("error")
		}

		return c, err
	}, 10)
}

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())

	/*
		mc := memcache.New("localhost:11211")
		mc.MaxIdleConns = 20
	*/

	fmt.Println("-------")
	svr1 := memcache.Server{Address: "localhost:11211", MaxConn: 64}
	mc, err := memcache.NewMemcache([]*memcache.Server{&svr1})
	if err != nil {
		panic(err)
	}
	mc.SetRemoveBadServer(true)
	fmt.Println("++++++")

	redisPool := SetupRedis()
	redisPool.Wait = true
	redisPool.IdleTimeout = 240 * time.Second
	redisPool.MaxActive = 10
	defer redisPool.Close()

	engine, err := xorm.NewEngine("postgres", "postgres://localhost/testdb?sslmode=disable")
	if err != nil {
		return
	}

	engine.SetMapper(core.SameMapper{})
	engine.ShowSQL(false)
	engine.SetMaxOpenConns(10)
	engine.SetMaxIdleConns(10)

	/*
		cfg := map[string]string{
			"conn": "localhost:6379",
			"key":  "default",
		}
		ccStore := cachestore.NewRedisCache(cfg)
		cacher := xorm.NewLRUCacher(ccStore, 99999999)
		engine.SetDefaultCacher(cacher)
	*/

	router := gin.New()
	render := eztemplate.New()
	render.TemplatesDir = "src/foobar/demo/views/"
	render.Layout = "layouts/base"
	render.Ext = ".html"

	router.HTMLRender = render.Init()

	router.GET("/json", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"hello": "world",
		})
	})

	router.GET("/redis", func(c *gin.Context) {
		rds := redisPool.Get()
		defer rds.Close()

		value, _ := redis.String(rds.Do("GET", "mydata"))

		c.String(200, value)
	})

	router.GET("/rest", func(c *gin.Context) {
		req := gorequest.New().Timeout(60000 * time.Millisecond)
		_, body, _ := req.Get("http://twitter.com").End()
		c.JSON(200, gin.H{
			"size": utf8.RuneCountInString(body),
		})
	})

	router.GET("/select", func(c *gin.Context) {
		item := Item{}
		has, _ := engine.Where("id = ?", 1).Get(&item)
		if has {
			c.JSON(200, gin.H{
				"id":    item.Id,
				"title": item.Title,
			})
		}
	})

	router.GET("/update", func(c *gin.Context) {
		item := Item{}
		has, _ := engine.Where("id = ?", 1).Get(&item)
		if has {
			item.Title = Reverse(item.Title)
			_, err := engine.Id(1).Update(&item)

			if err != nil {
				fmt.Println(err)
			} else {
				c.JSON(200, gin.H{
					"id":    item.Id,
					"title": item.Title,
				})
			}
		}
	})

	router.GET("/test", func(c *gin.Context) {
		c.HTML(http.StatusOK, "home/index", "O'Reilly: How are <i>you</i>?")
	})

	mc.Set("testkey", "HELLO,WORLD!")
	// mc.Set(&memcache.Item{Key: "testkey", Value: []byte("HELLO,WORLD.")})
	router.GET("/mc", func(c *gin.Context) {
		v, _, _ := mc.Get("testkey")
		c.String(200, v.(string))

		/*
			it, _ := mc.Get("testkey")
			c.String(200, string(it.Value))
		*/
	})

	 router.Run(":3000")
	 // router.RunUnix("/tmp/test.sock")
}
