from .proxy import ProxyAPI
from .healthcheck import HealthCheckAPI

PROXY_ROUTES = [
    "/",
    "/<path:path>"
]

def init_routes(api):
    api.add_resource(HealthCheckAPI, "/socks5-remote-proxy/v1/healthz")
    api.add_resource(ProxyAPI, *PROXY_ROUTES)
