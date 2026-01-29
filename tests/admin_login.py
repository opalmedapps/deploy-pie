# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "requests>=2.32.5",
#     "typer-slim>=0.21.1",
# ]
# ///
import requests
import typer

app = typer.Typer()


@app.command(context_settings={'ignore_unknown_options': True})
def main(admin_password: str):
    response = requests.post(
        'https://localhost/opalAdmin/user/validate-login',
        data={
            'username': 'admin',
            'password': admin_password,
        },
        timeout=5,
        allow_redirects=False,
        # during CI there won't be a valid cert
        verify=False,  # noqa: S501
    )

    if not response.ok:
        print(f'Admin login failed: {response.status_code} {response.text}')
        raise typer.Exit(code=1)

    print('Admin login succeeded')


if __name__ == '__main__':
    app()
