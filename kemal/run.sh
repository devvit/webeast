# crystal build src/bang.cr --release --no-debug
PORT=$1 PG_URL=postgres://localhost/testdb ./bang
