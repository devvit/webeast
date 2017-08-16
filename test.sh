#

for path in json get select update
do
	wrk --timeout 60 -t2 -c128 -d30s http://192.168.3.101$1/$path
done
