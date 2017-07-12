package org.example

import org.jetbrains.ktor.netty.*
import org.jetbrains.ktor.routing.*
import org.jetbrains.ktor.application.*
import org.jetbrains.ktor.host.*
import org.jetbrains.ktor.http.*
import org.jetbrains.ktor.response.*

import javax.persistence.Entity
import javax.persistence.Id
import javax.persistence.Table
import javax.persistence.MappedSuperclass

import redis.clients.jedis.*

import com.avaje.ebean.Ebean
import com.avaje.ebean.config.ServerConfig
import com.avaje.ebean.EbeanServerFactory
import com.avaje.ebean.Model
import com.avaje.ebean.Finder

import com.github.salomonbrys.kotson.*

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource

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

            val ds = HikariDataSource()
            ds.setJdbcUrl("jdbc:postgresql://localhost:5432/testdb")
            // ds.setDataSourceClassName("org.postgresql.ds.PGSimpleDataSource")
            // ds.setServerName("localhost")
            // ds.setPortNumber(5432)
            ds.setUsername("foo")
            ds.setPassword("")
            ds.setMaximumPoolSize(10)

            println(ds.getMaximumPoolSize())

            val config = ServerConfig()
            // config.name = "pg"
            config.isDefaultServer = true
            config.setDataSource(ds)
            // config.loadFromProperties()
            config.setClasses(arrayListOf<Class<*>>(Item::class.java))

            val server = EbeanServerFactory.create(config)

            val jedisCfg = JedisPoolConfig()
            jedisCfg.setMaxIdle(10)
            jedisCfg.setMaxTotal(10)
            jedisCfg.setMinIdle(10)
            jedisCfg.setBlockWhenExhausted(true)
            val jedisPool = JedisPool(jedisCfg, "localhost")

            embeddedServer(Netty, 3000) {
                routing {

                    get("/json") {
                        call.respondText(jsonObject("hello" to "world").toString(), ContentType.Application.Json)
                    }

                    get("/redis") {
                        val jedis: Jedis = jedisPool.getResource()
                        val v = jedis.get("mydata")
                        jedis.close()
                        call.respondText(v, ContentType.Text.Html)
                    }

                    get("/select") {
                        val item = Item.find.byId(1)
                        call.respondText(Ebean.json().toJson(item), ContentType.Application.Json)
                    }

                    get("/update") {
                        val item = Item.find.byId(1)
                        if (item != null) {
                            item.title = item.title.reversed()
                            item.save()
                            call.respondText(Ebean.json().toJson(item), ContentType.Application.Json)
                        }
                    }

                }
            }.start(wait = true)
        }
    }

}
