//

package org.example

import com.twitter.finagle.{Service, SimpleFilter}
import com.twitter.finagle.http.{Request, Response}
import com.twitter.finatra.http.HttpServer
import com.twitter.finatra.http.Controller
import com.twitter.finatra.http.filters.{CommonFilters, LoggingMDCFilter, TraceIdMDCFilter}
import com.twitter.finatra.http.routing.HttpRouter

import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource

import org.javalite.activejdbc.Base

import com.redis.RedisClientPool

object App extends MyServer

class MyController extends Controller {

  val rds = new RedisClientPool("localhost", 6379)

  get("/json") { request: Request =>
    // println("000000")
    "hello, finatra\n"
  }

  get("/get") { request: Request =>
    rds.withClient {
      client => {
        client.get("mydata")
      }
    }
  }

  get("/set") { request: Request =>
    rds.withClient {
      client => {
        client.set("uid", request.headerMap.get("X-Request-Id"))
      }
    }
  }

  get("/select") { request: Request =>
    val item = Item.fetch(1)
    item.toJson(false, "id", "title")
  }

  get("/update") { request: Request =>
    val item = Item.fetch(1)
    item.toJson(false, "id", "title")
    item.setTitle(item.get("title").toString().reverse)
    item.save()
    item.toJson(false, "id", "title")
  }
}

class MyFilter(ds: HikariDataSource) extends SimpleFilter[Request, Response] {

  def apply(
    request: Request,
    service: Service[Request, Response]
  ) = {
    // println("++++++")
    Base.open(ds)
    val nxt = service(request)
    Base.close()
    // println("------")
    nxt
  }
}

class MyServer extends HttpServer {

  override def configureHttp(router: HttpRouter) {
    val ds = new HikariDataSource()
    // ds.setJdbcUrl("jdbc:postgresql://localhost:5432/testdb")
    ds.setDataSourceClassName("org.postgresql.ds.PGSimpleDataSource")
    // ds.setDataSourceClassName("org.postgresql.ds.PGSimpleDataSource")
    // ds.setServerName("localhost")
    // ds.setPortNumber(5432)
    ds.addDataSourceProperty("databaseName", "testdb")
    ds.addDataSourceProperty("sslMode", "disable")
    ds.setUsername(sys.env("USER"))
    ds.setPassword("")
    ds.setMaximumPoolSize(10)

    val myf = new MyFilter(ds)
    router.filter(myf).add[MyController]
  }
}
