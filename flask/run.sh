gunicorn -b unix:///tmp/test.sock --worker-class="egg:meinheld#gunicorn_worker" --workers=2 $1
# uwsgi --http-socket /tmp/test.sock --wsgi-file myflask.py --callable app --processes 2 --threads 1 -M -L
