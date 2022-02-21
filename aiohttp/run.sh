#

n=$(($(nproc)*2))

gunicorn --bind unix:///tmp/test.sock --worker-class aiohttp.GunicornUVLoopWebWorker --workers=$n myapp:app_factory
