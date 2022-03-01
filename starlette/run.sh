#

export WEB_CONCURRENCY=$(($(nproc)*2))

uvicorn --uds /tmp/test.sock \
	--no-access-log \
	--loop uvloop \
	--http httptools \
	myapp:app
