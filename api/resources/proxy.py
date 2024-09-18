import json
import os

import requests
from flask import Response, request
from flask_restful import Resource

from api.libs.logging import init_logger


class Socks5ReverseProxyException(Exception):
    """base class for socks5 exceptions """


PROXY_URL = os.environ.get('PROXY_URL')
PROXY_PORT = os.environ.get('PROXY_PORT')
PROXIES = {
    'http': f"{PROXY_URL}:{PROXY_PORT}",
    'https': f"{PROXY_URL}:{PROXY_PORT}"
}
EXCLUDED_HEADERS = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']
TARGET_URL = os.environ.get('TARGET_URL', 'http://172.28.33.50')
LOG_LEVEL = os.environ.get('LOG_LEVEL', 'DEBUG')
LOG = init_logger(LOG_LEVEL)
LOG.info('proxy.py logging level %s', LOG_LEVEL)


class ProxyAPI(Resource):
    def get(self, path=None):
        if not path:
            url = f"{TARGET_URL}/"
        else:
            url = f"{TARGET_URL}/{path}"
        LOG.info("URL: %s", url)
        resp = requests.get(url, headers=request.headers, params=request.args, proxies=PROXIES)
        headers = [(name, value) for (name, value) in resp.raw.headers.items() if name.lower() not in EXCLUDED_HEADERS]
        response = Response(resp.content, resp.status_code, headers)
        return response

    def post(self):
        url = f"{TARGET_URL}/{request.path}"
        resp = requests.post(url, data=request.data, headers=request.headers, proxies=PROXIES)
        headers = [(name, value) for (name, value) in resp.raw.headers.items() if name.lower() not in EXCLUDED_HEADERS]
        response = Response(resp.content, resp.status_code, headers)
        return response

    def put(self):
        url = f"{TARGET_URL}/{request.path}"
        resp = requests.put(url, data=request.data, headers=request.headers, proxies=PROXIES)
        headers = [(name, value) for (name, value) in resp.raw.headers.items() if name.lower() not in EXCLUDED_HEADERS]
        response = Response(resp.content, resp.status_code, headers)
        return response