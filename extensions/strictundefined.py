from jinja2 import Environment, StrictUndefined
from jinja2.ext import Extension


class StrictUndefinedExtension(Extension):
    def __init__(self, environment: Environment):
        super().__init__(environment)
        environment.undefined = StrictUndefined
