# ufda: unspecified function describing automatons

## wat it is and why from da authors perspective

ever been tryin to understand a program an ur like "omfg this is so unnecessarily hard!!! uff da!!!!!" yea? me too! (ok not really[^name] uhm but close enough)

anyway the stuff in the ufda "suite" (rly just a repo that pins a few other repos that are separated for dubious reasons that i don't feel like revisiting yet) is meant to help solve that kinda problem.

- [ayxg](https://github.com/heartpunk/ayxg): a way of modeling arbitrary computation w/no ambiguities that is solver and proof friendly. basically fancy flowcharts, honestly. the edges (lines) are the rules that determine what state update happens in which condition, and the nodes (boxes/circles/shapes) are the symbolic/abstract states. in slightly more formal terms this is a symbolic transition system (STS) datatype and execution library in python and lean.
  - they're smt solver friendly already
  - there's a lean embedding so u can do proofs tho its not gonna be the easiest quite yet, and we haven't tried either tbqh
  - can v soon integrate w/vmt-lib and other kinds of solvers so all these models help bridge u to as much other literature/formalisms as possible
- [wruh](https://github.com/heartpunk/wruh): extracts models of binaries into ayxg STSes.
- [utem](https://github.com/heartpunk/utem): specializes fixed code or workload data through an ayxg model of an interpreter, compiler, vm, or kernel by way of a reference first futamura projector we've implemented and proved correct in lean.
- [ixyk](https://github.com/heartpunk/ixyk): a wruh like that is focused on reusable models per ISA mnemnonic. there's work to do to unify these and make the duality/tension between approaches apparent, and also allow for weirder mixed modes as well.

tl;dr: ufda plus some other planned stuff in the [roadmap](docs/roadmap.md) should, i think, in principle, *i hope*, be enough to get us all the way to first class and eventually even high level semantics for p much everything, even when we only have low level implementations.

if u want the reading list, there’s a [bibliography](docs/bibliography.md) w/a first ten and the rest grouped by what they’re useful for.

## boring ai slop. factually useful context but. like. up to u if u want that?

The UFDA suite brings together IXYK, WRUH, AYXG, and UTEM with pinned
sources and development commands.

Run `nix develop` to enter the suite environment. The wrappers stage immutable
source snapshots and separate writable build directories under
`$XDG_CACHE_HOME/ufda/component-clis` (or `~/.cache/ufda/component-clis`).
Each component flake pins its own dependencies, including IFRL as its
dependency/toolchain provider. UFDA preserves those pins. Each command enters
its component's own development shell.
Use `nix develop .#wruh` (or another component name) to enter that shell directly.
`nix eval --json .#lib.pins` prints the selected component revisions.

## Pins

All direct source inputs are pinned to full commit SHAs; advancing a branch or
bookmark does not change these selections.
These revisions align the component dependencies on one IFRL and AYXG revision.

| Component | Commit | Selection on 2026-10-19 |
| --- | --- | --- |
| IXYK | `8db2a865adc76ec0e07b2421b14db3318581f58e` | PR #83 |
| WRUH | `03abf8bde75094d82aabd4789f18643656368d72` | PR #3 |
| AYXG | `c7bd6ecc08a570c5b4a67643dcd33fc6c461bfec` | PR #4 |
| UTEM | `355c9f61b5cbae31807be633b7ffa66482915a83` | PR #1 |

## Commands

- `wruh-extract` (WRUH): extract a binary into an STS bundle.
- `wruh-compose` (WRUH): compose paths from an extracted STS bundle.
- `ixyk-dev-check`, `ixyk-golden-check`, `ixyk-differential-eval`
- `fuzz_model`, `extract_model`, `reapi_smoke` (IXYK)
- `bazelw` (WRUH)

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

All pinned component repositories are public and fetched over HTTPS.

## Checks

Run `bash tests/component-cli-contract.sh` for the existing wrapper behavior
checks, and `nix flake check --no-build --no-write-lock-file` to evaluate the
suite. These cover wrapper behavior and flake evaluation.

On Linux, `nix develop --command bash tests/wruh-cli-smoke.sh` exercises both
WRUH help commands, extracts a small compiled function, and composes the
resulting bundle. It also checks relative paths containing spaces.

[^name]: ufda only ended up being the name bcz something like umfa was generated as a shortcode and i was like teehee that's close to ufda which is like uff da and that made me decide to construct this white lie about having said uff da when i rly do not say such things i just grew up hearing about ppl saying it when my dad was a kid that is all. UPDATE slightly later same day: it is now a backronym. unspecified function describing automatons.
