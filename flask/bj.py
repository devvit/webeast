#

import sys

import bjoern

from myflask import app

if __name__ == '__main__':
	bjoern.run(app, f'unix://{sys.argv[1]}')
