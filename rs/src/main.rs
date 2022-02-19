//

use actix_web::{get, web, App, HttpServer, Responder, Result};
use serde::Serialize;

#[derive(Serialize)]
struct MyObj {
    hello: String,
}

#[get("/json")]
async fn h_json() -> Result<impl Responder> {
    let obj = MyObj {
        hello: "world".to_string(),
    };
    Ok(web::Json(obj))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| App::new().service(h_json))
        .bind_uds("/tmp/test.sock")?
        .run()
        .await
}

