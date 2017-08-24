gunicorn -b unix:///tmp/test.sock --worker-class="egg:meinheld#gunicorn_worker" --workers=2 $1
# uwsgi -s /tmp/test.sock --manage-script-name --processes 2 -M -L -l 1024 --threads 4 --mount /=$1
# uwsgi -s /tmp/test.sock --manage-script-name --processes 2 -M -L -l 1024 --gevent 100 --mount /=$1
