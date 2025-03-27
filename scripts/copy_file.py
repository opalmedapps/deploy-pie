import argparse
import shutil
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('source', type=Path)
parser.add_argument('target', type=Path)
parser.add_argument('--chmod', type=str)
args = parser.parse_args()

source: Path = args.source
target: Path = args.target
chmod: str | None = args.chmod

if chmod:
    try:
        chmod_octal = int(chmod, 8)
    except ValueError:
        print(f'Error: Invalid chmod value "{chmod}". Please provide a valid octal number.')
        exit(1)

if not source.is_file():
    print(f'Given source ({source}) is not a file')
    exit(1)

if not target.parent.is_dir():
    print(f"Given target's parent directory ({target.parent}) does not exist")
    exit(1)

shutil.copyfile(source, target)
print(f'Copied {source} to {target}')

if chmod is not None:
    target.chmod(chmod_octal)
    print(f'Set permissions to {chmod}')
