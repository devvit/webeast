RACK_ENV=production DATABASE_URL='postgres://localhost/testdb?pool=5' bundle exec thin -S /tmp/test.sock -s 2 -t 60 --max-conns 10000 $1
