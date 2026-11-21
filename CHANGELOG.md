# Changelog

## Unreleased

- `release.yml` attaches `release.json` to every release (`scripts/release-manifest.sh`: component, version, released,
  notes_url, summary, urgency `security` when the section has a `Security:` line, min_supported from an optional
  `MIN_SUPPORTED` file, and the URL and sha256 of each asset); new input `assets` lists files to attach. A `ci`
  workflow runs `tests/test_release_manifest.sh`.

## 1.1.0

- Org-wide pull request template and commit message template.

## 1.0.0

- Reusable verify (CI) and release (CD) workflows.
