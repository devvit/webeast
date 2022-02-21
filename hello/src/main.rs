//

#![allow(unused_must_use)]
#[macro_use]
extern crate rbatis;

use actix::Addr;
use actix_redis::{Command, RedisActor};
use actix_web::{error, get, web, App, HttpServer, Responder, Result};
use rbatis::core::db::DBPoolOptions;
use rbatis::crud::CRUD;
use rbatis::rbatis::Rbatis;
use redis_async::{resp::RespValue, resp_array};
use serde_json::json;
use std::env;
use std::sync::Arc;

#[crud_table(table_name:"items")]
#[derive(Clone, Debug)]
pub struct Item {
    pub id: Option<i32>,
    pub title: Option<String>,
}

impl Default for Item {
    fn default() -> Self {
        Item {
            id: None,
            title: None,
        }
    }
}

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

#[get("/select")]
async fn h_select(rb: web::Data<Arc<Rbatis>>) -> Result<impl Responder> {
    let item: Option<Item> = rb.fetch_by_column("id", 1).await.unwrap_or_default();
    // Ok(web::Json(json!({ "a": "b" })))
    Ok(web::Json(json!(item)))
}

#[get("/update")]
async fn h_update(rb: web::Data<Arc<Rbatis>>) -> Result<impl Responder> {
    let item: Item = rb.fetch_by_column("id", 1).await.unwrap();
    let new_item = &Item {
        id: Some(1),
        title: Some(item.title.unwrap().to_string().chars().rev().collect()),
    };
    rb.update_by_column("id", new_item).await;
    Ok(web::Json(json!(new_item)))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // fast_log::init_log("requests.log", log::Level::Info, None, true);
    // log::info!("linking database...");

    let mut opt = DBPoolOptions::new();
    opt.max_connections = 30;

    let rb = Rbatis::new();
    rb.link_opt("postgres://localhost/testdb", opt)
        .await
        .expect("rbatis link database fail");
    let rb = Arc::new(rb);
    // log::info!("linking database successful!");

    let s = HttpServer::new(move || {
        let redis_addr = RedisActor::start("localhost:6379");

        App::new()
            .app_data(web::Data::new(redis_addr))
            .app_data(web::Data::new(rb.to_owned()))
            .service(h_json)
            .service(h_get)
            .service(h_select)
            .service(h_update)
    });
    let port = env::var("PORT");
    if port.is_err() {
        s.bind_uds("/tmp/test.sock")?.run().await
    } else {
        s.bind("127.0.0.1:8888")?.run().await
    }
}
