# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "requests>=2.32.5",
#     "typer-slim>=0.21.1",
# ]
# ///
import requests
import typer


def main(labs_password: str):
    response = requests.post(
        'http://localhost/opalAdmin/user/system-login',
        data={
            'username': 'interface-engine',
            'password': labs_password,
        },
        timeout=5,
        allow_redirects=False,
        # during CI there won't be a valid cert
        verify=False,  # noqa: S501
    )

    if not response.ok:
        print(f'System user login failed: {response.status_code} {response.text}')
        raise typer.Exit(code=1)

    print('System user login succeeded')


if __name__ == '__main__':
    typer.run(main)
