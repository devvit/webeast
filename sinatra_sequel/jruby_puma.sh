# jrubyrc
# compile.invokedynamic=true
# objectspace.enabled=false

JRUBY_OPTS='-J-Djruby.thread.pool.enabled=true -J-Xmn512m -J-Xms512m -J-Xmx512m -J-server' RACK_ENV=production DATABASE_URL='jdbc:postgresql://localhost/testdb' bundle exec puma -t 16
