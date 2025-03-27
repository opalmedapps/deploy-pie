from pathlib import Path

from jinja2 import Environment
from jinja2.ext import Extension


def file_exists(file: str) -> bool:
    filepath = Path(file)
    return filepath.exists() and filepath.is_file()


def directory_exists(directory: str) -> bool:
    dirpath = Path(directory)
    return dirpath.exists() and dirpath.is_dir()


def is_readable(file: str) -> bool:
    filepath = Path(file)

    try:
        with filepath.open():
            return True
    except OSError:
        pass

    return False


def is_absolute(path: str) -> bool:
    return Path(path).is_absolute()


def is_directory(path: str) -> bool:
    return Path(path).is_dir()


class PathsExtension(Extension):
    def __init__(self, environment: Environment):
        super().__init__(environment)
        environment.globals["file_exists"] = file_exists
        environment.globals["directory_exists"] = directory_exists
        environment.globals["is_readable"] = is_readable
        environment.globals['is_absolute'] = is_absolute
        environment.globals['is_directory'] = is_directory
