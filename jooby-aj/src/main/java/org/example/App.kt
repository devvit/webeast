//

package org.example

import org.jooby.*

import redis.clients.jedis.*

import com.github.salomonbrys.kotson.*

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource

import org.javalite.activejdbc.Base

class App {
    companion object {
        @JvmStatic fun main(args: Array<String>) {

            run(*args) {
                val ds = HikariDataSource()
                // ds.setJdbcUrl("jdbc:postgresql://localhost:5432/testdb")
                ds.setDataSourceClassName("org.postgresql.ds.PGSimpleDataSource")
                // ds.setDataSourceClassName("org.postgresql.ds.PGSimpleDataSource")
                // ds.setServerName("localhost")
                // ds.setPortNumber(5432)
                ds.addDataSourceProperty("databaseName", "testdb")
                ds.addDataSourceProperty("sslMode", "disable")
                ds.setUsername(System.getenv()["USER"])
                ds.setPassword("")
                ds.setMaximumPoolSize(10)

                // redis
                val jedisCfg = JedisPoolConfig()
                jedisCfg.setMaxIdle(10)
                jedisCfg.setMaxTotal(10)
                jedisCfg.setMinIdle(10)
                jedisCfg.setBlockWhenExhausted(true)
                val jedisPool = JedisPool(jedisCfg, "localhost")


                before(Route.Before({ _, _ ->
                    Base.open(ds)
                    // println("++++++ ++++++")
                }))

                after(Route.After({ _, _, result ->
                    Base.close()
                    // println("------ ------")
                    result
                }))

                get("/json") {
                    "hello Jooby\n"
                }

                get("/get") {
                    (jedisPool.getResource()).use { jedis ->
                        jedis.get("mydata")
                    }
                }

                get("/set") { req ->
                    (jedisPool.getResource()).use { jedis ->
                        jedis.set("uid", req.header("X-Request-Id").value())
                    }
                }

                get("/select") {
                    val item = Item.fetch(1)
                    item.toJson(false, "id", "title")
                }

                get("/update") {
                    val item = Item.fetch(1)
                    item.setTitle(item.get("title").toString().reversed())
                    item.save()
                    item.toJson(false, "id", "title")
                }

            }
        }
    }
}
