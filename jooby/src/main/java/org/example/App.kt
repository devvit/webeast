package org.example

import javax.persistence.Entity
import javax.persistence.Id
import javax.persistence.Table
import javax.persistence.MappedSuperclass

import com.avaje.ebean.Ebean
import com.avaje.ebean.config.ServerConfig
import com.avaje.ebean.EbeanServerFactory
import com.avaje.ebean.Model
import com.avaje.ebean.Finder

import com.github.salomonbrys.kotson.*

import org.jooby.*
import org.jooby.jedis.*
import org.jooby.ebean.*

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
                use(Redis::class)

                get("/json") {
                    jsonObject("hello" to "world").toString()
                }

                get("/redis") {
                    val jedis = require(Jedis::class)
                    val v = jedis.get("mydata")
                    // jedis.close()
                    v
                }
            }

        }

    }

}
