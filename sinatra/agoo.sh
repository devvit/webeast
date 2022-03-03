#

n=$(($(nproc)*2))

agoo -w $n -t $n -b unix:///tmp/test.sock
