#!/bin/bash
# scripts/release-manifest.sh <owner/repo> <version> <out.json> [asset...]: the release.json every better-ade release
# carries, so tools (ade) can tell a new version, its urgency and each asset's sha256. Reads CHANGELOG.md (the
# "## <version>" section) and the optional MIN_SUPPORTED file in the current folder. Needs python3.
#   component     the repo's name             notes_url  the release page
#   version       X.Y.Z                       summary    the section's first non-empty line (a leading "- " dropped)
#   released      UTC time (or $RELEASED)     urgency    "security" when a line of the section starts "Security:"
#   min_supported MIN_SUPPORTED or null       files      [{name, url, sha256}] per asset
set -eu
[ $# -ge 3 ] || { echo "usage: release-manifest.sh <owner/repo> <version> <out.json> [asset...]" >&2; exit 2; }
repo="$1" version="$2" out="$3"; shift 3
echo "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' || { echo "release-manifest: '$version' is not X.Y.Z" >&2; exit 2; }
[ -f CHANGELOG.md ] || { echo "release-manifest: no CHANGELOG.md here" >&2; exit 1; }
python3 - "$repo" "$version" "$out" "${RELEASED:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}" "${RELEASE_BASE:-https://github.com}" "$@" <<'PY'
import hashlib, json, os, re, sys
repo, version, out, released, base, assets = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6:]
section, on = [], False
for line in open("CHANGELOG.md", encoding="utf-8"):
    m = re.match(r"^## +\[?v?([^\]\s]+)\]?", line)
    if m:
        on = m.group(1) == version
        continue
    if on:
        section.append(line.rstrip("\n"))
if not section or not any(l.strip() for l in section):
    sys.exit("release-manifest: CHANGELOG.md has no '## %s' section" % version)
first = next(l.strip() for l in section if l.strip())
summary = re.sub(r"^[-*] +", "", first)
security = any(re.match(r"^\s*(?:[-*]\s+)?(?:\*\*)?Security:", l) for l in section)
mins = None
if os.path.exists("MIN_SUPPORTED"):
    mins = open("MIN_SUPPORTED").read().strip()
    if not re.match(r"^[0-9]+\.[0-9]+\.[0-9]+$", mins):
        sys.exit("release-manifest: MIN_SUPPORTED '%s' is not X.Y.Z" % mins)
files = []
for a in assets:
    if not os.path.isfile(a):
        sys.exit("release-manifest: no asset %s" % a)
    name = os.path.basename(a)
    files.append({"name": name, "url": "%s/%s/releases/download/v%s/%s" % (base, repo, version, name),
                  "sha256": hashlib.sha256(open(a, "rb").read()).hexdigest()})
d = {"component": repo.split("/")[-1], "version": version, "released": released,
     "notes_url": "%s/%s/releases/tag/v%s" % (base, repo, version), "summary": summary,
     "urgency": "security" if security else "normal", "min_supported": mins, "files": files}
with open(out, "w") as f:
    json.dump(d, f, indent=2); f.write("\n")
PY
