package com.example.starter;

import io.vertx.core.AbstractVerticle;
import io.vertx.core.Future;
import io.vertx.core.Promise;
import io.vertx.core.json.Json;
import io.vertx.core.json.JsonObject;
import io.vertx.ext.web.Router;
import io.vertx.pgclient.PgConnectOptions;
import io.vertx.pgclient.PgPool;
import io.vertx.redis.client.Command;
import io.vertx.redis.client.Redis;
import io.vertx.redis.client.RedisAPI;
import io.vertx.redis.client.RedisOptions;
import io.vertx.redis.client.Request;
import io.vertx.sqlclient.PoolOptions;
import io.vertx.sqlclient.Row;
import io.vertx.sqlclient.Tuple;

public class MainVerticle extends AbstractVerticle {
  private static int MAX_POOL = 10;

  @Override
  public void start(Promise<Void> startPromise) throws Exception {
    PgConnectOptions connectOptions = new PgConnectOptions()
      .setUser("foo")
      .setDatabase("testdb");
    PoolOptions poolOptions = new PoolOptions()
      .setMaxSize(MAX_POOL);
    PgPool pool = PgPool.pool(vertx, connectOptions, poolOptions);

    Redis client = Redis.createClient(
        vertx,
        new RedisOptions()
        .setConnectionString("redis://localhost")
        .setMaxPoolSize(MAX_POOL)
        );

    Router router = Router.router(vertx);

    router.get("/json").respond(
        ctx -> Future.succeededFuture(new JsonObject().put("hello", "world"))
        );

    router.get("/get").handler(ctx -> {
      client.connect().compose(conn -> {
        return conn.send(Request.cmd(Command.GET).arg("hello")).onSuccess(v -> {
          ctx.response().end(Json.encode(new JsonObject().put("hello", v.toString())));
        }).onComplete(x -> conn.close());
      });
    });

    router.get("/select").handler(
        ctx -> {
          pool.getConnection().compose(conn -> {
            return conn
              .query("SELECT * FROM items WHERE id = 1")
              .execute()
              .onSuccess(rows -> {
                Row row = rows.iterator().next();
                ctx.response().end(Json.encode(
                      new JsonObject().put("id", row.getInteger("id")).put("title", row.getString("title"))
                      ));
              })
            .onComplete(ar -> conn.close());
          });
        }
        );

    router.get("/update").handler(
        ctx -> {
          pool.getConnection().compose(conn -> {
            return conn
              .query("SELECT * FROM items WHERE id = 1")
              .execute()
              .onSuccess(rows -> {
                Row row = rows.iterator().next();
                String title = new StringBuffer(row.getString("title")).reverse().toString();
                conn
                  .preparedQuery("update items set title = $1 where id = 1")
                  .execute(Tuple.of(title))
                  .onSuccess(rows2 -> {
                    ctx.response().end(Json.encode(
                          new JsonObject().put("id", row.getInteger("id")).put("title", title)
                          ));
                  });
              })
            .onComplete(ar -> conn.close());
          });
        }
    );

    vertx.createHttpServer().requestHandler(router).listen(8888, http -> {
      if (http.succeeded()) {
        startPromise.complete();
        System.out.println("HTTP server started on port 8888");
      } else {
        startPromise.fail(http.cause());
      }
    });
  }
}
