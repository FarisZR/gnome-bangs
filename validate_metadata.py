import json
import re
from pathlib import Path


root = Path(__file__).resolve().parent
metadata = json.loads((root / 'metadata.json').read_text(encoding='utf-8'))

required_fields = {
    'name',
    'description',
    'uuid',
    'shell-version',
    'url',
    'settings-schema',
}

missing_fields = sorted(required_fields - metadata.keys())
if missing_fields:
    raise SystemExit(f"Missing metadata fields: {', '.join(missing_fields)}")

shell_versions = metadata.get('shell-version', [])
if not isinstance(shell_versions, list):
    raise SystemExit('shell-version must be a JSON array')

if not shell_versions:
    raise SystemExit('shell-version must not be empty')

if not all(isinstance(version, str) for version in shell_versions):
    raise SystemExit('shell-version entries must be strings')

try:
    numeric_versions = [int(version) for version in shell_versions]
except ValueError as error:
    raise SystemExit(f'shell-version entries must be numeric strings: {error}') from error

if numeric_versions != sorted(numeric_versions):
    raise SystemExit('shell-version entries must be sorted')

if len(shell_versions) != len(set(shell_versions)):
    raise SystemExit('shell-version entries must be unique')

readme = (root / 'README.md').read_text(encoding='utf-8')
support_pattern = re.compile(
    rf'GNOME Shell\s+{re.escape(shell_versions[0])}\s*(?:through|-|to)\s*{re.escape(shell_versions[-1])}'
)
if not support_pattern.search(readme):
    raise SystemExit('README.md must document the supported GNOME Shell version range')

required_files = [
    root / 'extension.js',
    root / 'prefs.js',
    root / 'bang.png',
    root / 'schemas' / 'org.gnome.shell.extensions.bangs.gschema.xml',
]

missing_files = [str(path.relative_to(root)) for path in required_files if not path.exists()]
if missing_files:
    raise SystemExit(f"Missing required file(s): {', '.join(missing_files)}")

print('Metadata validation passed.')
