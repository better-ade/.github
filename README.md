# better-ade/.github

Shared CI/CD for every better-ade repo, so they all work the same way:

- `VERSION` (X.Y.Z) and `CHANGELOG.md` (`## X.Y.Z` sections) at the repo root.
- **CI** (`verify.yml`): every pull request and push to main runs the repo's verification command and a gitleaks scan.
- **CD** (`release.yml`): when `VERSION` on main names a version with no tag yet, the checks run, then `vX.Y.Z` is tagged
  and released with that version's changelog section. Bump `VERSION` and add the changelog section in the same PR.
  Each release also carries `release.json` (`scripts/release-manifest.sh`): version, a one-line summary, `urgency`
  (`security` when the section has a `Security:` line), `min_supported` (an optional `MIN_SUPPORTED` file) and the
  sha256 of each asset named in the `assets` input. `ade` reads it to announce and verify updates.
- main requires the `ci` check.

A repo calls them:

```yaml
jobs:
  ci: { uses: better-ade/.github/.github/workflows/verify.yml@v1, with: { command: "bash tests/run.sh" } }
```

Both take `command` (required), `runs-on` (default `ubuntu-latest`) and `setup` (shell lines run first); `verify.yml`
also takes `timeout-minutes` (default 45), `release.yml` also `assets` (files to attach and hash in `release.json`).
The `v1` tag is today at 1.2.0.

This repo also holds the organisation's profile page, [`profile/README.md`](profile/README.md), which links every
better-ade repo and the website, [ade.ardata.tech](https://ade.ardata.tech/).

## Commit and PR standard (every better-ade repo)

- **Pull requests** use `pull_request_template.md` (GitHub applies it to every repo in the org without its own):
  Overview, Implementation details, Verification (real output, who ran it, review by risk), Definition of Done
  checklist, Related PRs, issues, stories and ADRs.
- **Commits** follow `commit-template.txt` (`git config commit.template <path>`): a one-line summary, then Overview,
  Implementation, Verification, Done and Related.
- Commits and PRs go out under the author's own git identity, with no AI attribution.
