import zoneinfo

from jinja2.ext import Extension


def valid_timezone(timezone: str) -> bool:
    return timezone in zoneinfo.available_timezones()


class TimezoneExtension(Extension):
    def __init__(self, environment):
        super().__init__(environment)
        environment.filters['valid_timezone'] = valid_timezone
