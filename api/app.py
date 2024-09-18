import logging
import os

from flask import Flask, request
from flask_restful import Api
from flask_cors import CORS

from api.libs.logging import init_logger
from api.resources.routes import init_routes

class Socks5ReverseProxyException(Exception):
    """base class for socks5 exceptions """


LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO')
APP_NAME = __name__.split('.')[0]

APP = Flask(APP_NAME, instance_path='/opt/app/api', root_path='/opt/app/api')
API = Api(APP)

LOG = init_logger(LOG_LEVEL)
init_routes(API)
LOG.info('Routes initialized')

