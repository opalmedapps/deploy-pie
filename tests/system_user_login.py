# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "requests>=2.32.5",
#     "typer-slim>=0.21.1",
# ]
# ///
import requests
import typer


def main(username: str, password: str):
    print(f'Attempting system user login for user: {username}')

    response = requests.post(
        'https://localhost/opalAdmin/user/system-login',
        data={
            'username': username,
            'password': password,
        },
        timeout=5,
        allow_redirects=False,
        # during CI there won't be a valid cert
        verify=False,  # noqa: S501
    )

    if not response.ok:
        print(f'System user login failed: {response.status_code} {response.text}')
        raise typer.Exit(code=1)

    print(f'System user login succeeded for user: {username}')


if __name__ == '__main__':
    typer.run(main)
