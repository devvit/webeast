gunicorn -b unix:///tmp/test.sock -t 60 --keep-alive=120 --workers=2 --worker-class="egg:meinheld#gunicorn_worker" $1
# uwsgi --http-socket /tmp/test.sock --wsgi-file myflask.py --callable app --processes 2 --threads 1 -M -L
