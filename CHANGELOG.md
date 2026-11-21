# Changelog

## 1.2.0

- `release.yml` attaches `release.json` to every release (`scripts/release-manifest.sh`: component, version, released,
  notes_url, summary, urgency `security` when the section has a `Security:` line, min_supported from an optional
  `MIN_SUPPORTED` file, and the URL and sha256 of each asset); new input `assets` lists files to attach. A `ci`
  workflow runs `tests/test_release_manifest.sh`.

## 1.1.1

- verify.yml: the job has a time limit (`timeout-minutes`, default 45), so a hung test fails instead of holding a runner for six hours.

## 1.1.0

- Org-wide pull request template and commit message template.

## 1.0.0

- Reusable verify (CI) and release (CD) workflows.
