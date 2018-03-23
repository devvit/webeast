gunicorn --bind unix:///tmp/test.sock --worker-class aiohttp.GunicornUVLoopWebWorker --workers=2 aio_app:app_factory
