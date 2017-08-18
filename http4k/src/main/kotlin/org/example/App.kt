//

package org.example

import java.util.*

import redis.clients.jedis.*

import com.github.salomonbrys.kotson.*

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource

import org.http4k.core.Filter
import org.http4k.core.HttpHandler
import org.http4k.core.Method.GET
import org.http4k.core.Request
import org.http4k.core.Response
import org.http4k.core.Status.Companion.OK
import org.http4k.core.then
import org.http4k.filter.CachingFilters
import org.http4k.routing.bind
import org.http4k.routing.path
import org.http4k.routing.routes
import org.http4k.server.Netty
import org.http4k.server.asServer
import org.http4k.filter.ServerFilters

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

            val myFilter = Filter {
                next: HttpHandler -> { request: Request ->
                    Base.open(ds)
                    val response = next(request)
                    Base.close()
                    response
                }
            }

            val app: HttpHandler = routes(
                    "/json" bind GET to { req: Request ->
                        Response(OK).body("helli, http4k")
                    },
                    "/get" bind GET to { req: Request ->
                        (jedisPool.getResource()).use { jedis ->
                            Response(OK).body(jedis.get("mydata"))
                        }
                    },
                    "/set" bind GET to { req: Request ->
                        (jedisPool.getResource()).use { jedis ->
                            Response(OK).body(jedis.set("uid", req.header("X-Request-Id")))
                        }
                    },
                    "/select" bind GET to { req: Request ->
                        val item = Item.fetch(1)
                        item.setTitle(item.get("title").toString().reversed())
                        Response(OK).body(item.toJson(false, "id", "title"))
                    },
                    "/update" bind GET to { req: Request ->
                        val item = Item.fetch(1)
                        item.setTitle(item.get("title").toString().reversed())
                        item.save()
                        Response(OK).body(item.toJson(false, "id", "title"))
                    }
            )

            myFilter.then(app).asServer(Netty(3000)).start()
        }
    }

}
