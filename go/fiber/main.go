package main

import (
  "github.com/gofiber/fiber/v2"
)

func main() {
  app := fiber.New(fiber.Config{
    Prefork: true,
  })

  app.Get("/json", func(c *fiber.Ctx) error {
    return c.JSON(fiber.Map{
      "hello": "world",
    })
  })

  app.Listen(":8888")
}
