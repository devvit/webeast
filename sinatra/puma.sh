RACK_ENV=production DATABASE_URL='postgres://localhost/testdb?pool=5' bundle exec puma -w 2 -t 1:1 -b unix:///tmp/test.sock
