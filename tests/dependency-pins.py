"""Check that suite, Nix, Lake, and Bazel declarations select the same sources."""

import json
from pathlib import Path
import re
import subprocess


root = Path(__file__).resolve().parents[1]


def evaluate(attribute):
    return json.loads(subprocess.check_output(
        ["nix", "eval", "--json", "--no-write-lock-file", f".#lib.{attribute}"],
        cwd=root,
    ))


lock = json.loads((root / "flake.lock").read_text())
revisions = {}
for node in lock["nodes"].values():
    source = node.get("locked", {})
    if "owner" in source and "repo" in source:
        repository = (source["owner"], source["repo"])
        revisions.setdefault(repository, set()).add(source["rev"])
for repository, selected in revisions.items():
    assert len(selected) == 1, (repository, selected)

pins = evaluate("pins")
sources = {name: Path(path) for name, path in evaluate("sources").items()}
assert set(pins) == set(sources) == {"ayxg", "ixyk", "utem", "wruh"}
assert set(lock["nodes"][lock["root"]]["inputs"]) == set(pins)
for name, revision in pins.items():
    assert revisions[("heartpunk", name)] == {revision}, name

ifrl_revision, = revisions[("heartpunk", "ifrl")]
for name in ("ixyk", "wruh"):
    module = (sources[name] / "MODULE.bazel").read_text()
    override, = re.findall(
        r'git_override\(\s*module_name\s*=\s*"ifrl"\s*,(.*?)\)',
        module, re.S,
    )
    assert re.search(r'commit\s*=\s*"' + ifrl_revision + r'"', override), name

for consumer, dependencies in (("wruh", ("ayxg",)), ("utem", ("ayxg", "wruh"))):
    lakefile = (sources[consumer] / "lakefile.lean").read_text()
    for dependency in dependencies:
        assert re.search(
            rf'require {dependency} from git\s+"https://github.com/heartpunk/'
            rf'{dependency}\.git"\s*@\s*"{pins[dependency]}"', lakefile,
        ), (consumer, dependency)

manifest = json.loads((sources["utem"] / "lake-manifest.json").read_text())
for package in manifest["packages"]:
    if package["name"] in ("ayxg", "wruh"):
        assert package["rev"] == package["inputRev"] == pins[package["name"]]

print("One revision per repository; suite, Nix, Lake, and Bazel pins agree.")
