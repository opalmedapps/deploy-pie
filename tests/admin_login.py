# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "requests>=2.32.5",
#     "typer-slim>=0.21.1",
# ]
# ///
import requests
import typer


def main(admin_password: str):
    response = requests.post(
        'http://localhost/opalAdmin/user/validate-login',
        data={
            'username': 'admin',
            'password': admin_password,
        },
        timeout=5,
        allow_redirects=False,
    )

    if not response.ok:
        print(f'Admin login failed: {response.status_code} {response.text}')
        raise typer.Exit(code=1)

    print('Admin login succeeded')


if __name__ == '__main__':
    typer.run(main)
