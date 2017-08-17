//

package org.example

import java.util.*

import redis.clients.jedis.*

import com.github.salomonbrys.kotson.*

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource

import org.javalite.activejdbc.Base

import org.jetbrains.ktor.application.*
import org.jetbrains.ktor.host.*
import org.jetbrains.ktor.http.*
import org.jetbrains.ktor.netty.*
import org.jetbrains.ktor.response.*
import org.jetbrains.ktor.routing.*

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

            val server = embeddedServer(Netty, 3000) {
                routing {

                    intercept(ApplicationCallPipeline.Infrastructure) {
                        // println("++++++")
                        Base.open(ds)
                        proceed()
                        Base.close()
                        // println("------")
                    }

                    get("/json") {
                        // println("000000")
                        call.respondText("hello ktor\n", ContentType.Text.Html)
                    }

                    get("/get") {
                        (jedisPool.getResource()).use { jedis ->
                            call.respondText(jedis.get("mydata"), ContentType.Text.Html)
                        }
                    }

                    get("/set") {
                        (jedisPool.getResource()).use { jedis ->
                            call.respondText(jedis.set("uid", call.request.headers.get("X-Request-Id")), ContentType.Text.Html)
                        }
                    }

                    get("/select") {
                        val item = Item.fetch(1)
                        call.respondText(item.toJson(false, "id", "title"), ContentType.Application.Json)
                    }

                    get("/update") {
                        val item = Item.fetch(1)
                        item.setTitle(item.get("title").toString().reversed())
                        item.save()
                        call.respondText(item.toJson(false, "id", "title"), ContentType.Application.Json)
                    }
                }
            }
            server.start(wait = true)
        }
    }

}
