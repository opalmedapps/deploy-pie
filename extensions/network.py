import socket
from contextlib import closing

from jinja2 import Environment
from jinja2.ext import Extension


# source: https://stackoverflow.com/a/35370008
def is_port_available(port: int, host: str = 'localhost') -> bool:
    """Check if a port is available on a given host (or localhost by default)."""
    print(f'Checking availability of port {port} on host {host}...')

    with closing(socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as sock:
        return_code = sock.connect_ex((host, port))

        if return_code == 0:
            print(f'Port {port} on host {host} is open (not available)')
        else:
            print(f'Port {port} on host {host} is closed (available)')

        return return_code != 0


class NetworkExtension(Extension):
    def __init__(self, environment: Environment):
        super().__init__(environment)
        environment.globals['is_port_available'] = is_port_available
