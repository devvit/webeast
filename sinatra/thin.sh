RACK_ENV=production DATABASE_URL='postgres://localhost/testdb?pool=5' bundle exec thin -S /tmp/test.sock -s 4 $1
