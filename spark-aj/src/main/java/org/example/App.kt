//

package org.example

import spark.Spark.*
import spark.Filter

import java.util.*

import redis.clients.jedis.*

import com.github.salomonbrys.kotson.*

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource

import org.javalite.activejdbc.Base

class App {

    companion object {
        @JvmStatic fun main(args: Array<String>) {

            val ds = HikariDataSource()
            // ds.setJdbcUrl("jdbc:postgresql://localhost:5432/testdb")
            ds.setDataSourceClassName("org.postgresql.ds.PGSimpleDataSource")
            // ds.setDataSourceClassName("org.postgresql.ds.PGSimpleDataSource")
            // ds.setServerName("localhost")
            // ds.setPortNumber(5432)
            ds.addDataSourceProperty("databaseName", "testdb")
            ds.addDataSourceProperty("sslMode", "disable")
            ds.setUsername("foo")
            ds.setPassword("")
            ds.setMaximumPoolSize(10)

            // redis
            val jedisCfg = JedisPoolConfig()
            jedisCfg.setMaxIdle(10)
            jedisCfg.setMaxTotal(10)
            jedisCfg.setMinIdle(10)
            jedisCfg.setBlockWhenExhausted(true)
            val jedisPool = JedisPool(jedisCfg, "localhost")

            port(System.getenv("PORT").toInt())
            threadPool(10)

            before(Filter({ req, res ->
                // System.out.println("++++++")
                Base.open(ds)
            }))

            after(Filter({ req, res ->
                // System.out.println("------")
                Base.close()
            }))

            get("/json") { req, res ->
                "hello spark\n"
            }

            get("/get") { req, res ->
                (jedisPool.getResource()).use { jedis ->
                    jedis.get("mydata")
                }
            }

            get("/set") { req, res ->
                (jedisPool.getResource()).use { jedis ->
                    jedis.set("uid", req.headers("X-Request-Id"))
                }
            }

            get("/select") { req, res ->
                val item = Item.fetch(1)
                item.toJson(false, "id", "title")
            }

            get("/update") { req, res ->
                val item = Item.fetch(1)
                item.setTitle(item.get("title").toString().reversed())
                item.save()
                item.toJson(false, "id", "title")
            }
        }
    }

}
