# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "requests>=2.32.5",
#     "typer-slim>=0.21.1",
# ]
# ///
import requests
import typer


def main(name: str, token: str):
    response = requests.get(
        'https://localhost/api/auth/user/',
        headers={
            'Authorization': f'Token {token}',
        },
        timeout=5,
        allow_redirects=False,
        # during CI there won't be a valid cert
        verify=False,  # noqa: S501
    )

    if not response.ok:
        print(f'Token with name {name} is invalid: {response.status_code} {response.text}')
        raise typer.Exit(code=1)

    print(f'Token with name {name} is valid')


if __name__ == '__main__':
    typer.run(main)
