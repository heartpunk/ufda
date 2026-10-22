#!/usr/bin/env bash
set -euo pipefail

suite_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
cd "$suite_root"
wruh_source=$(nix eval --raw --no-write-lock-file .#lib.sources.wruh)
nix develop .#wruh --no-write-lock-file --command bash -euo pipefail -c '
  export PYTHONPATH="$1:$WRUH_AYXG_SOURCE/python"
  python -m extractor.angr_smt_smoke
' -- "$wruh_source"

# Exercise the Bazel dependency graph through the same wrapper users run.
nix develop --no-write-lock-file --command bazelw \
  --batch --host_jvm_args=-Xmx512m --host_jvm_args=-XX:ActiveProcessorCount=2 \
  test --jobs=2 --loading_phase_threads=2 --test_output=errors //extractor:angr_runtime_smoke
nix develop --no-write-lock-file --command bash tests/wruh-cli-smoke.sh
