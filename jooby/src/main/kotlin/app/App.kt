package app

import io.ebean.Database
import io.jooby.Kooby
import io.jooby.json.JacksonModule
import io.jooby.redis.RedisModule
import io.jooby.require
import io.jooby.runApp
import io.lettuce.core.api.StatefulRedisConnection
import io.lettuce.core.api.sync.RedisCommands
import javax.persistence.Entity
import io.jooby.hikari.HikariModule
import io.jooby.ebean.EbeanModule
import javax.persistence.Id
import javax.persistence.Table

@Entity
@Table(name="items")
class Item {
    @Id
    var id: Long = 0

    var title: String = ""
}

class App : Kooby({
    install(JacksonModule())
        install(RedisModule())
        install(HikariModule())
        install(EbeanModule())

        serverOptions {
            port = 8888
        }

    get("/json") {
        mapOf("hello" to "world")
    }

    get("/get") {
        val redis = require(StatefulRedisConnection::class)
            val syncCommands = redis.sync() as RedisCommands<String, String>
            mapOf("hello" to syncCommands.get("hello"))
    }

    get("/select") {
        val db = require(Database::class)
            val item = db.find(Item::class.java, 1)
            mapOf("id" to item.id, "title" to item.title)
    }

    get("/update") {
        val db = require(Database::class)
            val item = db.find(Item::class.java, 1)
            item.title = item.title.reversed()
            db.save(item)
            mapOf("id" to item.id, "title" to item.title)
    }
})

fun main(args: Array<String>) {
    runApp(args, App::class)
}
