# UFDA

The UFDA suite brings together IXYK, WRUH, AYXG, UTEM, and TMVM (TinyMemory) with pinned
sources and development commands.

Run `nix develop` to enter the suite environment. The wrappers stage immutable
source snapshots and separate writable build directories under
`$XDG_CACHE_HOME/ufda/component-clis` (or `~/.cache/ufda/component-clis`).
Each component flake pins its own dependencies, including IFRL as its
dependency/toolchain provider. UFDA preserves those pins. Each command enters
its component's own development shell.
Use `nix develop .#tmvm` (or another component name) to enter that shell directly.
`nix eval --json .#lib.pins` prints the selected component revisions.

## Pins

All direct source inputs are pinned to full commit SHAs; advancing a branch or
bookmark does not change these selections.
AYXG and WRUH select the existing bisimulation PR heads.

| Component | Commit | Selection on 2026-10-19 |
| --- | --- | --- |
| IXYK | `b6779bb0ed4354c820fb831be1f4402170a0e5d1` | main tip |
| WRUH | `16d77877512d97fad0622a7a6ac401cf8b2dd538` | PR #2 |
| AYXG | `5106df06d92620da810c325b8779ce97a14f7f0e` | PR #1 |
| UTEM | `88efa92e1fe4c0553f8eba43dec198b19ebdeb31` | main tip |
| TMVM | `7b2935541d5537c09db7354daee6f98ff74a265e` | rebuilt mainline |

## Commands

- `wruh-extract` (WRUH): extract a binary into an STS bundle.
- `wruh-compose` (WRUH): compose paths from an extracted STS bundle.
- `ixyk-dev-check`, `ixyk-golden-check`, `ixyk-differential-eval`
- `fuzz_model`, `extract_model`, `reapi_smoke` (IXYK)
- `bazelw` (WRUH)
- `tinymemory-bounded-oracle` (TMVM)

`wruh-extract` runs WRUH's `python -m extractor.extract_cli`;
`wruh-compose` runs `python -m extractor.compose_cli`. Both use WRUH's own
development shell and the AYXG source selected by that shell. Arguments pass
through unchanged, and relative input/output paths are resolved from your
current directory.

```sh
nix develop
wruh-extract --help
wruh-compose --help
wruh-extract --artifact ./program --root function_name --output ./bundle.json
wruh-compose --input ./bundle.json --output ./paths.json
```

The separate `extract_model` command runs IXYK's Bazel target of that name.

## Repository access

UFDA, TMVM, and UTEM are currently private. TMVM and UTEM are fetched over SSH
at their pinned commits; using the suite requires GitHub access to both repositories.

## Checks

Run `bash tests/component-cli-contract.sh` for the existing wrapper behavior
checks, and `nix flake check --no-build --no-write-lock-file` to evaluate the
suite. These cover wrapper behavior and flake evaluation.

On Linux, `nix develop --command bash tests/wruh-cli-smoke.sh` exercises both
WRUH help commands, extracts a small compiled function, and composes the
resulting bundle. It also checks relative paths containing spaces.
