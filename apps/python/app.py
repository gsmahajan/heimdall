import socket
import logging

from flask import Flask

logger = logging.getLogger('myapp')
hdlr = logging.FileHandler('app.log')
formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr)
logger.setLevel(logging.INFO)

app = Flask(__name__)


class Hits:
    def __init__(self):
        self._count = 0

    def one_more(self):
        self._count += 1

    def current(self):
        return self._count


hits = Hits()


@app.route('/')
def hello():
    logger.info('Handling the "/" request...')
    logger.info('My Hostname is "%s"', socket.gethostname())
    logger.info('current index is %s', hits.current())
    hits.one_more()
    logger.info('I have been seen %s times', hits.current())
    html = '<p>{}</p>'.format(hits.current())
    logger.info('HTML: %s', html)
    return html


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
