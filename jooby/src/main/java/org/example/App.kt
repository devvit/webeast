//

package org.example

import org.jooby.*

import javax.persistence.Entity
import javax.persistence.Id
import javax.persistence.Table
import javax.persistence.MappedSuperclass

import redis.clients.jedis.*

import io.ebean.Ebean
import io.ebean.config.ServerConfig
import io.ebean.EbeanServerFactory
import io.ebean.Model
import io.ebean.Finder

import com.github.salomonbrys.kotson.*

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource

import redis.clients.jedis.Jedis

@MappedSuperclass
abstract class AbsModel : Model() {
}

open class ItemFinder : Finder<Long, Item> {
    constructor() : super(Item::class.java) {}
    constructor(serverName:String) : super(Item::class.java, serverName) {}
}

@Entity
@Table(name="items")
class Item : AbsModel() {
    @Id
    var id: Int = 0

    var title: String = ""

    companion object find : ItemFinder() {}
}

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

                val config = ServerConfig()
                // config.name = "pg"
                config.isDefaultServer = true
                config.setDataSource(ds)
                // config.loadFromProperties()
                config.setClasses(arrayListOf<Class<*>>(Item::class.java))

                val server = EbeanServerFactory.create(config)

                // redis
                val jedisCfg = JedisPoolConfig()
                jedisCfg.setMaxIdle(10)
                jedisCfg.setMaxTotal(10)
                jedisCfg.setMinIdle(10)
                jedisCfg.setBlockWhenExhausted(true)
                val jedisPool = JedisPool(jedisCfg, "localhost")

                get("/json") {
                    jsonObject("hello" to "world").toString()
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

                get("/select") { req ->
                    val item = Item.find.byId(1)
                    Ebean.json().toJson(item)
                }

                get("/update") { req ->
                    var v = ""
                    val item = Item.find.byId(1)
                    if (item != null) {
                        item.title = item.title.reversed()
                        item.save()
                        v = Ebean.json().toJson(item)
                    }
                    v
                }

            }
        }
    }
}
