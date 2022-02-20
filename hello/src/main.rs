//

use actix::Addr;
use actix_redis::{Command, RedisActor};
use actix_web::{error, get, web, App, HttpServer, Responder, Result};
use redis_async::{resp::RespValue, resp_array};
use serde_json::json;
use std::env;

#[get("/json")]
async fn h_json() -> Result<impl Responder> {
    Ok(web::Json(json!({ "hello": "world" })))
}

#[get("/get")]
async fn h_get(redis: web::Data<Addr<RedisActor>>) -> Result<impl Responder> {
    let res = redis
        .send(Command(resp_array!["GET", "hello"]))
        .await
        .map_err(error::ErrorInternalServerError)?;
    match res {
        Ok(RespValue::BulkString(x)) => Ok(web::Json(
            json!({ "hello": Some(std::str::from_utf8(&x).unwrap().to_string()) }),
        )),
        _ => Ok(web::Json(json!({}))),
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let s = HttpServer::new(|| {
        let redis_addr = RedisActor::start("127.0.0.1:6379");
        App::new()
            .app_data(web::Data::new(redis_addr))
            .service(h_json)
            .service(h_get)
    });
    let port = env::var("PORT");
    if port.is_err() {
        s.bind_uds("/tmp/test.sock")?.run().await
    } else {
        s.bind("127.0.0.1:8888")?.run().await
    }
}

