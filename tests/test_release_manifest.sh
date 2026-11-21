#!/bin/bash
# scripts/release-manifest.sh: a valid release.json with every field and correct sha256 values (story A12, AC1)
set -u; S="$(cd "$(dirname "$0")/.." && pwd)/scripts/release-manifest.sh"
fail() { echo "FAIL: $*" >&2; exit 1; }
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT; cd "$T" || exit 1
cat > CHANGELOG.md <<'C'
# Changelog

## Unreleased
- not this

## 1.2.0
- `ade update` checks sha256 values.
- More.

## 1.1.0
- Security: fix the token leak.
C
printf 'one\n' > ade; printf 'two\n' > install.sh
RELEASED=2026-11-22T00:00:00Z bash "$S" better-ade/ade-cli 1.2.0 out.json ade install.sh || fail "normal run"
python3 - out.json "$(shasum -a 256 ade 2> /dev/null | cut -d' ' -f1 || sha256sum ade | cut -d' ' -f1)" <<'PY' || fail "fields"
import json, sys
d = json.load(open(sys.argv[1]))
assert set(d) == {"component", "version", "released", "notes_url", "summary", "urgency", "min_supported", "files"}, d
assert d["component"] == "ade-cli" and d["version"] == "1.2.0" and d["released"] == "2026-11-22T00:00:00Z", d
assert d["notes_url"] == "https://github.com/better-ade/ade-cli/releases/tag/v1.2.0", d
assert d["summary"] == "`ade update` checks sha256 values.", d
assert d["urgency"] == "normal" and d["min_supported"] is None, d
assert [f["name"] for f in d["files"]] == ["ade", "install.sh"], d
assert d["files"][0]["sha256"] == sys.argv[2], d
assert d["files"][0]["url"] == "https://github.com/better-ade/ade-cli/releases/download/v1.2.0/ade", d
PY
echo 1.0.0 > MIN_SUPPORTED; bash "$S" better-ade/ade-cli 1.1.0 sec.json || fail "security run"
python3 -c 'import json,sys; d=json.load(open("sec.json")); assert d["urgency"] == "security" and d["min_supported"] == "1.0.0" and d["files"] == [], d' || fail "security and min_supported"
bash "$S" better-ade/ade-cli 9.9.9 none.json 2> /dev/null && fail "a version with no section is refused"
bash "$S" better-ade/ade-cli 1.2.0 x.json missing 2> /dev/null && fail "a missing asset is refused"
echo bad > MIN_SUPPORTED; bash "$S" better-ade/ade-cli 1.2.0 x.json 2> /dev/null && fail "a bad MIN_SUPPORTED is refused"
bash "$S" better-ade/ade-cli 1.2 x.json 2> /dev/null && fail "a bad version is refused"
echo ok
