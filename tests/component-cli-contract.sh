#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
base_path=$PATH
bash_path=$(command -v bash)
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/ufda-cli-contract.XXXXXX")
cleanup() {
  chmod -R u+w "$tmp_root" 2>/dev/null || true
  rm -rf "$tmp_root"
}
trap cleanup EXIT

mkdir -p "$tmp_root/bin" "$tmp_root/source/bin" "$tmp_root/caller/relative"
cat > "$tmp_root/bin/nix" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\0' "$@" > "$NIX_CAPTURE"
while (($#)); do
  if [[ $1 == --command ]]; then
    shift
    exec "$@"
  fi
  shift
done
exit 97
STUB
cat > "$tmp_root/bin/bazel" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
cat > "$tmp_root/source/bin/cli" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\0' "$PWD" "$@" > "$CAPTURE_FILE"
cat > "$STDIN_CAPTURE"
printf 'stub stdout\n'
printf 'stub stderr\n' >&2
exit "${STUB_EXIT:-0}"
STUB
chmod +x "$tmp_root/bin/nix" "$tmp_root/bin/bazel" "$tmp_root/source/bin/cli"
: > "$tmp_root/caller/relative/input file.json"

stale_cache="$tmp_root/cache/ufda/component-clis/contract/cache-test"
mkdir -p "$stale_cache/flake" "$stale_cache/worktree"
printf '%s\n' 'contract:rev-test:cache-test' > "$stale_cache/.ready"
printf '%s\n' 'keep this user edit' > "$stale_cache/worktree/user-edit"

printf 'stub stdout\n' > "$tmp_root/expected-stdout"
printf 'stub stderr\n' > "$tmp_root/expected-stderr"
export PATH="$tmp_root/bin:$base_path"
export XDG_CACHE_HOME="$tmp_root/cache"
export CAPTURE_FILE="$tmp_root/capture"
export STDIN_CAPTURE="$tmp_root/stdin-capture"
export NIX_CAPTURE="$tmp_root/nix-capture"
cd "$tmp_root/caller"

run_cli() {
  bash "$repo_root/scripts/component-cli" \
    contract rev-test "$tmp_root/source" cache-test \
    bazel-binary //stub:cli bin/cli "$bash_path" -- "$@"
}

assert_capture() {
  printf '%s\0' "$PWD" "$@" > "$tmp_root/expected-args"
  cmp -s "$tmp_root/expected-args" "$CAPTURE_FILE" || {
    printf '%s\n' 'component-cli contract: arguments or caller directory changed' >&2
    exit 1
  }
}

assert_streams() {
  local input_path=$1
  cmp -s "$input_path" "$STDIN_CAPTURE" || {
    printf '%s\n' 'component-cli contract: stdin was not forwarded' >&2
    exit 1
  }
  cmp -s "$tmp_root/expected-stdout" "$tmp_root/actual-stdout" || {
    printf '%s\n' 'component-cli contract: stdout was not forwarded' >&2
    exit 1
  }
  cmp -s "$tmp_root/expected-stderr" "$tmp_root/actual-stderr" || {
    printf '%s\n' 'component-cli contract: stderr was not forwarded' >&2
    exit 1
  }
}

printf 'stdin with no arguments\n' > "$tmp_root/input-empty"
run_cli < "$tmp_root/input-empty" > "$tmp_root/actual-stdout" 2> "$tmp_root/actual-stderr"
assert_capture
assert_streams "$tmp_root/input-empty"
printf '%s\n' 'component-cli contract: no arguments and standard streams passed'

printf 'stdin with arguments\n' > "$tmp_root/input-args"
export STUB_EXIT=37
set +e
run_cli --help '' 'value with spaces' 'relative/input file.json' \
  < "$tmp_root/input-args" > "$tmp_root/actual-stdout" 2> "$tmp_root/actual-stderr"
status=$?
set -e
if [[ $status -ne 37 ]]; then
  printf 'component-cli contract: expected exit 37, got %s\n' "$status" >&2
  exit 1
fi
assert_capture --help '' 'value with spaces' 'relative/input file.json'
assert_streams "$tmp_root/input-args"
printf '%s\n' 'component-cli contract: arguments, caller directory, and exit status passed'

new_cache="$tmp_root/cache/ufda/component-clis/contract/readonly-flake-v2-cache-test"
if [[ -w "$new_cache/flake" || -w "$new_cache/flake/bin/cli" ]]; then
  printf '%s\n' 'component-cli contract: staged flake checkout is writable' >&2
  exit 1
fi
if [[ ! -w "$new_cache/worktree" || ! -w "$new_cache/worktree/bin/cli" ]]; then
  printf '%s\n' 'component-cli contract: staged worktree is not writable' >&2
  exit 1
fi
if [[ $(cat "$stale_cache/worktree/user-edit") != 'keep this user edit' ]]; then
  printf '%s\n' 'component-cli contract: stale cache user edit was changed' >&2
  exit 1
fi
printf '%s\n' 'component-cli contract: read-only flake and stale cache preservation passed'

printf '%s\0' develop --no-write-lock-file "$new_cache/flake" \
  > "$tmp_root/expected-nix-prefix"
prefix_bytes=$(wc -c < "$tmp_root/expected-nix-prefix")
head -c "$prefix_bytes" "$NIX_CAPTURE" > "$tmp_root/actual-nix-prefix"
cmp -s "$tmp_root/expected-nix-prefix" "$tmp_root/actual-nix-prefix" || {
  printf '%s\n' 'component-cli contract: component own flake was not used' >&2
  exit 1
}
printf '%s\n' 'component-cli contract: component own flake passed'

# Exercise the Python launch path with a shell-selected AYXG dependency.
mkdir -p "$tmp_root/selected ayxg/python/ayxg"
cat > "$tmp_root/bin/python" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\0' "$PYTHONPATH" > "$PYTHONPATH_CAPTURE"
printf '%s\0' "$PWD" "$@" > "$CAPTURE_FILE"
cat > "$STDIN_CAPTURE"
printf 'stub stdout\n'
printf 'stub stderr\n' >&2
exit "${STUB_EXIT:-0}"
STUB
chmod +x "$tmp_root/bin/python"
export WRUH_AYXG_SOURCE="$tmp_root/selected ayxg"
export PYTHONPATH="$tmp_root/inherited-python-path"
export PYTHONPATH_CAPTURE="$tmp_root/pythonpath-capture"
for module in extractor.extract_cli extractor.compose_cli; do
  export STUB_EXIT=37
  set +e
  bash "$repo_root/scripts/component-cli" \
    contract rev-test "$tmp_root/source" cache-test \
    wruh-python "$module" '' "$bash_path" -- \
    --help '' 'relative/input file.json' \
    < "$tmp_root/input-args" > "$tmp_root/actual-stdout" 2> "$tmp_root/actual-stderr"
  wrapper_status=$?
  set -e
  [[ $wrapper_status -eq 37 ]] || exit 1
  assert_capture -m "$module" --help '' 'relative/input file.json'
  assert_streams "$tmp_root/input-args"
  printf '%s\0' "$new_cache/flake:$WRUH_AYXG_SOURCE/python:$PYTHONPATH" > "$tmp_root/expected-pythonpath"
  cmp -s "$tmp_root/expected-pythonpath" "$PYTHONPATH_CAPTURE"
done
printf '%s\n' 'component-cli contract: WRUH modules, selected AYXG, paths, streams, and exit status passed'
