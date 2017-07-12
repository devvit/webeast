#

import sys

import meinheld

from myflask import app


if __name__ == '__main__':
    # usock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    # usock.bind('/tmp/test.sock')
    meinheld.set_keepalive(120)
    meinheld.set_access_logger(None)
    meinheld.set_error_logger(None)
    meinheld.listen(sys.argv[1].encode())
    meinheld.run(app)
