# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "requests>=2.32.5",
#     "typer-slim>=0.21.1",
# ]
# ///
import json
from http import HTTPStatus

import requests
import typer


def main(labs_password: str):
    print(requests.get('http://localhost/opalAdmin/', verify=False).status_code)  # noqa: S113, S501
    print(requests.get('http://localhost/opalAdmin/', verify=False).headers)  # noqa: S113, S501
    response = requests.post(
        'http://localhost/opalAdmin/labs/api/processLabForPatient.php',
        auth=('interface-engine', labs_password),
        data=json.dumps({
            'mrn': 'test',
            'site': 'test',
            'labOrders': [],
        }),
        timeout=5,
        allow_redirects=False,
        # during CI there won't be a valid cert
        verify=False,  # noqa: S501
    )

    print(response.status_code, response.headers)

    if (
        response.status_code == HTTPStatus.BAD_REQUEST
        and response.json().get('reason') == 'Opal patient with Mrn: test, Site: test not found.'
    ):
        print('Labs request with basic auth succeeded')
    else:
        print(f'Labs request with basic auth failed: {response.status_code} {response.text}')
        raise typer.Exit(code=1)


if __name__ == '__main__':
    typer.run(main)
