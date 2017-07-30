rackup -s Rhebok -O Path=/tmp/test.sock -O MaxWorkers=4 -O MaxRequestPerChild=1000 -E production config.ru
