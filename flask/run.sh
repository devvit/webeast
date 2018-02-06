gunicorn -b unix:///tmp/test.sock --worker-class="egg:meinheld#gunicorn_worker" --workers=2 $1
# uwsgi -s /tmp/test.sock --manage-script-name --processes 2 -M -L --threads 16 --mount /=$1
# uwsgi -s /tmp/test.sock --manage-script-name --processes 2 -M -L --gevent 100 --mount /=$1
