RACK_ENV=production DATABASE_URL='postgres://localhost/testdb?pool=5' bundle exec puma -b unix:///tmp/test.sock -w 2 -t 8:8
