package com.example.starter;

import io.vertx.ext.web.*;
import io.vertx.core.http.*;
import io.vertx.core.*;
import io.vertx.core.json.*;
import io.vertx.redis.client.*;
import io.vertx.pgclient.*;
import io.vertx.sqlclient.*;

public class MainVerticle extends AbstractVerticle {

  int MAX_POOL = 20;

  @Override
  public void start(Promise<Void> startPromise) throws Exception {
    HttpServer server = vertx.createHttpServer();
    Router router = Router.router(vertx);

    Redis client = Redis.createClient(
        vertx,
        new RedisOptions()
        .setConnectionString("redis://localhost")
        .setMaxPoolSize(MAX_POOL)
        );
    RedisAPI redis = RedisAPI.api(client);

    PgConnectOptions connectOptions = new PgConnectOptions()
      .setHost("localhost")
      .setPort(5432)
      .setDatabase("testdb")
      .setUser("foo");
    Pool pool = Pool.pool(vertx, connectOptions, new PoolOptions().setMaxSize(MAX_POOL));

    router
      .get("/json")
      .respond(
          ctx -> Future.succeededFuture(new JsonObject().put("hello", "world")));

    router
      .get("/get")
      .handler(ctx -> {
        redis
          .get("hello")
          .onSuccess(value -> {
            ctx.response().end(Json.encode(new JsonObject().put("hello", "world")));
          });
      });

    router
      .get("/select")
      .handler(ctx -> {
        pool.query("SELECT * FROM items where id = 1")
          .execute()
          .onSuccess(rows -> {
            Row row = rows.iterator().next();
            ctx.response().end(Json.encode(
                  new JsonObject().put("id", row.getInteger("id")).put("title", row.getString("title"))
                  ));
          });
      });

    router
      .get("/update")
      .handler(ctx -> {
        pool.query("SELECT * FROM items where id = 1")
          .execute()
          .onSuccess(rows -> {
            Row row = rows.iterator().next();
            String title = new StringBuffer(row.getString("title")).reverse().toString();
            pool
              .preparedQuery("update items set title = $1 where id = 1")
              .execute(Tuple.of(title))
              .onSuccess(rows2 -> {
                ctx.response().end(Json.encode(
                      new JsonObject().put("id", row.getInteger("id")).put("title", title)
                      ));
              });
          });
      });


    server.requestHandler(router).listen(8888, http -> {
      if (http.succeeded()) {
        startPromise.complete();
        System.out.println("HTTP server started on port 8888");
      } else {
        startPromise.fail(http.cause());
      }
    });
  }
}
