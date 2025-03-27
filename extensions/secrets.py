import secrets
from pathlib import Path
from typing import Optional

import bcrypt
from jinja2 import Environment
from jinja2.ext import Extension


def random_password(length: Optional[int] = None) -> str:
    return secrets.token_urlsafe(length)


def random_token(length: Optional[int] = None) -> str:
    return secrets.token_hex(length)


def bcrypt_hash(value: str) -> str:
    return bcrypt.hashpw(value.encode(), bcrypt.gensalt(prefix=b'2a')).decode()


def existing_secret(path: str, name: str) -> str:
    with Path(path).open() as file:
        for line in file.readlines():
            if line.startswith(f'{name}='):
                return line.split('=')[1].strip().removeprefix('"').removesuffix('"')

    return ''


class SecretsExtension(Extension):
    def __init__(self, environment: Environment):
        super().__init__(environment)
        environment.globals['random_password'] = random_password
        environment.globals['random_token'] = random_token
        environment.globals['bcrypt'] = bcrypt_hash
        environment.globals['existing_secret'] = existing_secret
