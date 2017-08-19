//

package org.example

import io.vertx.kotlin.core.json.*

import io.vertx.core.AbstractVerticle
import io.vertx.core.Future
import io.vertx.core.Handler
import io.vertx.core.http.HttpServerResponse
import io.vertx.core.json.Json
import io.vertx.ext.web.Router
import io.vertx.ext.web.RoutingContext
import io.vertx.redis.RedisClient
import io.vertx.ext.jdbc.JDBCClient

import com.github.salomonbrys.kotson.*

class App : AbstractVerticle() {
    lateinit var rds : RedisClient
    lateinit var mydb : JDBCClient

    override fun start(startFuture: Future<Void>?) {
        val router = createRouter()

        mydb = JDBCClient.createShared(vertx, json {
            obj(
                    "provider_class" to "io.vertx.ext.jdbc.spi.impl.HikariCPDataSourceProvider",
                    "jdbcUrl" to "jdbc:postgresql://localhost/testdb",
                    "max_pool_size" to 10,
                    "maximumPoolSize" to 10
            )
        })


        rds = RedisClient.create(vertx)


        vertx.createHttpServer()
        .requestHandler { router.accept(it) }
        .listen(3000) { result ->
            if (result.succeeded()) {
                startFuture?.complete()
            } else {
                startFuture?.fail(result.cause())
            }
        }
    }

    private fun createRouter() = Router.router(vertx).apply {
        get("/json").handler(handlerRoot)
        get("/get").handler(redisGet)
        get("/set").handler(redisSet)
        get("/select").handler(handleSelect)
        get("/update").handler(handleUpdate)
    }

    val handlerRoot = Handler<RoutingContext> { ctx ->
        ctx.response().end(jsonObject("hello" to "world").toString())
    }

    val redisGet = Handler<RoutingContext> { ctx ->
        rds.get("mydata", { r ->
            ctx.response().end(r.result())
        })
    }

    val redisSet = Handler<RoutingContext> { ctx ->
        rds.set("uid", ctx.request().getHeader("X-Request-Id"), { r ->
            ctx.response().end("$(r.succeeded())")
        })
    }

    val handleSelect = Handler<RoutingContext> { ctx ->
        mydb.getConnection({ res  ->
            val conn = res.result()
            conn.query("SELECT * FROM items where id = 1", { r ->
                val rs = r.result().rows
                val item = rs[0]
                val v = jsonObject("title" to item.getString("title"), "id" to item.getInteger("id"))
                conn.close()
                ctx.response().end(v.toString())
            })
        })
    }

    val handleUpdate = Handler<RoutingContext> { ctx ->
        mydb.getConnection({ res  ->
            val conn = res.result()
            conn.query("SELECT * FROM items where id = 1", { r ->
                val rs = r.result().rows
                val item = rs[0]

                conn.updateWithParams("update items set title = ? where id = 1", json { array(item.getString("title").reversed()) }, { effect ->

                    val v = jsonObject("title" to item.getString("title"), "id" to item.getInteger("id"), "result" to effect.result().updated)
                    conn.close()
                    ctx.response().end(v.toString())

                })
            })
        })
    }
}
