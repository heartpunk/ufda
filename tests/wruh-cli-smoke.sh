#!/usr/bin/env bash
set -euo pipefail

# Run from UFDA's default shell: nix develop --command bash tests/wruh-cli-smoke.sh
suite_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
test_root=$(mktemp -d "${TMPDIR:-/tmp}/ufda-wruh-smoke.XXXXXX")
trap 'rm -rf "$test_root"' EXIT
mkdir -p "$test_root/caller with spaces"
cd "$test_root/caller with spaces"

cat > program.c <<'C'
__attribute__((noinline)) long ufda_increment(long value) { return value + 1; }
int main(void) { return (int)ufda_increment(1); }
C
cc -O0 -g -fno-pie -no-pie program.c -o 'input program'

wruh-extract --help > extract-help.txt
wruh-compose --help > compose-help.txt
grep -q -- '--artifact' extract-help.txt
grep -q -- '--input' compose-help.txt

wruh-extract --artifact './input program' --root ufda_increment --root-only \
  --output './extracted bundle.json'
wruh-compose --input './extracted bundle.json' --output './composed paths.json'

nix develop --no-write-lock-file "$suite_root#wruh" --command python - <<'PY'
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(os.environ['WRUH_AYXG_SOURCE']) / 'python'))
from ayxg.codec import loads

bundle = loads(Path('extracted bundle.json').read_text())
composed = loads(Path('composed paths.json').read_text())
assert bundle['schema'] == 'wruh-fresh-bundle-v1'
assert bundle['root_id'] == 'ufda_increment'
assert bundle['functions'], 'Extraction produced no functions'
assert composed['schema'] == 'wruh-composed-paths-v1'
assert composed['root_id'] == bundle['root_id']
assert composed['image_sha256'] == bundle['image_sha256']
assert composed['paths'], 'Composition produced no paths'
print('WRUH smoke: both help commands and extract/compose with relative paths containing spaces passed')
PY
