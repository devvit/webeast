#

n=$(($(nproc) * 2))

RACK_ENV=production bundle exec puma -b unix:///tmp/test.sock -w $n -t $n:$n
