# Git Workflow & Branching Strategy

This document defines how we manage source code, branches, pull requests, and releases on GitHub. It is the source of truth for our team's day-to-day Git workflow.

**Audience:** all developers working on the project.

---

## 1. Branch Model

We use three long-lived branches. Code flows **upward only** — never sideways, never downward (except hotfix back-merges).

```
development  ──▶  staging  ──▶  main (live)
   (WIP)          (UAT/QA)        (production)
```


| Branch        | Purpose                                                                                             | State    |
| ------------- | --------------------------------------------------------------------------------------------------- | -------- |
| `main`        | Exactly what is live in production. Every commit is deployable. Tagged with semver on each release. | Live     |
| `staging`     | Release candidate. Code that has passed dev review and is waiting for QA/UAT sign-off.              | Pre-prod |
| `development` | Integration branch. All completed feature work lands here first.                                    | WIP      |


**Rules:**

- Never commit directly to `main`, `staging`, or `development`. Always go through a Pull Request.
- Code only moves upward: `feature → development → staging → main`.
- The only exception is **hotfix**, which branches off `main` (see §7).

---

## 2. Short-Lived Branches

All everyday work happens on short-lived branches.


| Prefix                        | Purpose                              | Branches off  | Merges into                                        |
| ----------------------------- | ------------------------------------ | ------------- | -------------------------------------------------- |
| `feature/PROJ-123-short-desc` | New functionality                    | `development` | `development`                                      |
| `bugfix/PROJ-123-short-desc`  | Non-urgent bug fix                   | `development` | `development`                                      |
| `hotfix/PROJ-123-short-desc`  | Urgent production bug                | `main`        | `main` (then cherry-pick to staging + development) |
| `chore/short-desc`            | Tooling, deps, build, docs           | `development` | `development`                                      |
| `release/vX.Y.Z` *(optional)* | Pre-release stabilization on staging | `staging`     | `main` (then back to staging)                      |


### Naming rules

- All lowercase, kebab-case description.
- Include the Plane ticket ID where applicable (e.g. `PROJ-123`).
- Keep total branch name under ~60 characters.
- Examples:
  - `feature/PROJ-142-customer-search`
  - `bugfix/PROJ-201-invoice-rounding`
  - `hotfix/PROJ-999-checkout-crash`
  - `chore/upgrade-flutter-3-29`

### Cleanup

- Delete the remote branch immediately after merging the PR (enable "Automatically delete head branches" in repo settings).
- Delete the local branch after merge: `git branch -d feature/PROJ-123-foo`.

---

## 3. Commit Messages — Conventional Commits

Every commit follows the [Conventional Commits](https://www.conventionalcommits.org/) specification.

```
<type>(<scope>): <short summary>

[optional body explaining the WHY, not the WHAT]

[optional footer: PROJ-123, BREAKING CHANGE:, Co-Authored-By:]
```

### Types


| Type       | When to use                                             |
| ---------- | ------------------------------------------------------- |
| `feat`     | New feature for the user                                |
| `fix`      | Bug fix for the user                                    |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `chore`    | Build, tooling, dependencies, repo hygiene              |
| `docs`     | Documentation only                                      |
| `test`     | Adding or updating tests only                           |
| `style`    | Formatting, whitespace, no code change                  |
| `perf`     | Performance improvement                                 |
| `build`    | Build system or external dependencies                   |
| `ci`       | CI/CD config changes                                    |


### Examples

```
feat(customer): add address book API integration

Implements GET/POST/PUT /address-book endpoints in the customer module.
Adds caching at the repository layer to reduce redundant network calls.

PROJ-142
```

```
fix(invoice): correct rounding when discount exceeds subtotal

PROJ-201
```

### Rules

- Subject line: imperative mood, lowercase, no period, ≤72 characters.
- Body: wrap at ~100 characters; explain **why**, not what.
- Footer: include the Plane ticket ID on every commit.
- Use `BREAKING CHANGE:` in the footer for any backward-incompatible change.

---

## 4. Pull Request Workflow

Every change goes through a PR. Every PR follows this lifecycle.

### Promotion flow

```
feature/PROJ-123 ──PR──▶ development ──PR──▶ staging ──PR──▶ main
  (1 approval)            (2 approvals          (2 approvals
                          + CODEOWNERS)         + CODEOWNERS)
```

### PR checklist (every PR)

- Branch name follows the naming rules.
- Title follows Conventional Commits format.
- Linked to a Plane ticket.
- Description includes summary, screenshots (UI changes), and a test plan.
- Tests added or updated for new behavior.
- Docs updated if behavior, public APIs, or setup changed.
- No debug logs, commented-out code, or unexplained TODOs.
- Self-reviewed before requesting review.
- CI green.

### Merge strategies (per target)


| Target branch                             | Strategy           | Why                                                   |
| ----------------------------------------- | ------------------ | ----------------------------------------------------- |
| `development` (from feature/bugfix/chore) | **Squash & merge** | One clean commit per ticket on the integration branch |
| `staging` (from development)              | **Merge commit**   | Preserve the list of features going to QA             |
| `main` (from staging or hotfix)           | **Merge commit**   | Audit trail of exactly what shipped in each release   |


Disable rebase-merge in repo settings (Settings → General → Pull Requests) to keep the model consistent across the team.

---

## 5. Branch Protection Rules

Configure under **Settings → Branches → Add rule** for each long-lived branch.


| Rule                                             | `development` | `staging`  | `main`                       |
| ------------------------------------------------ | ------------- | ---------- | ---------------------------- |
| Require a PR before merging                      | ✅             | ✅          | ✅                            |
| Required approving reviews                       | 1             | 2          | 2                            |
| Dismiss stale approvals on new commits           | ✅             | ✅          | ✅                            |
| Require review from CODEOWNERS                   | —             | ✅          | ✅                            |
| Require status checks to pass (CI, lint, tests)  | ✅             | ✅          | ✅                            |
| Require branches to be up to date before merging | ✅             | ✅          | ✅                            |
| Require conversation resolution before merging   | ✅             | ✅          | ✅                            |
| Require signed commits                           | optional      | ✅          | ✅                            |
| Require linear history                           | ❌             | ❌          | ❌                            |
| Include administrators (no bypass)               | ✅             | ✅          | ✅                            |
| Restrict who can push                            | dev team      | tech leads | tech leads + release manager |
| Allow force pushes                               | ❌             | ❌          | ❌                            |
| Allow deletions                                  | ❌             | ❌          | ❌                            |


---

## 6. CODEOWNERS

`.github/CODEOWNERS` auto-requests the right reviewers based on file paths.

Example:

```
# Default owner — everything not matched below
*                       @org/tech-leads

# Area owners
/lib/features/auth/             @org/auth-team
/lib/features/billing/          @org/payments-team
/lib/features/customer/         @org/customer-team
/lib/core/                      @org/tech-leads
/.github/                       @org/devops
/docs/                          @org/tech-leads
```

Update this file whenever a new area of code gets a dedicated owner.

---

## 7. Hotfix Flow

When a bug is found in production but `staging` and `development` already contain unrelated WIP that isn't ready to ship.

```
1. Branch off main:
     git checkout main
     git pull
     git checkout -b hotfix/PROJ-999-fix-checkout-crash

2. Fix the bug, add a regression test, commit.

3. Open a PR: hotfix/PROJ-999 ──▶ main
     (2 approvals + CODEOWNERS, full CI must pass)

4. Merge to main → tag the release → deploy.
     git tag -a v1.4.2 -m "hotfix: checkout crash"
     git push origin v1.4.2

5. Cherry-pick the fix into staging:
     git checkout staging && git pull
     git cherry-pick <commit-sha>
     # Open a PR: cherry-pick/PROJ-999-to-staging ──▶ staging (1 approval)

6. Cherry-pick the fix into development:
     git checkout development && git pull
     git cherry-pick <commit-sha>
     # Open a PR: cherry-pick/PROJ-999-to-development ──▶ development (1 approval)
```

**Why cherry-pick instead of merging main downward:** merging `main` into `staging`/`development` would drag the release state with it. Cherry-picks isolate the fix.

If the file has diverged heavily and the cherry-pick conflicts badly, open a follow-up `bugfix/PROJ-999-port-to-dev` branch and re-implement the fix on top of current `development`.

---

## 8. Release Tagging on `main`

Every merge into `main` (whether from `staging` or `hotfix`) is followed by an annotated semver tag.

### SemVer increment rules


| Change                            | Bump                    |
| --------------------------------- | ----------------------- |
| Breaking API/contract change      | `MAJOR` (1.4.2 → 2.0.0) |
| New feature, backward-compatible  | `MINOR` (1.4.2 → 1.5.0) |
| Bug fix only (including hotfixes) | `PATCH` (1.4.2 → 1.4.3) |


### Tagging

```bash
git checkout main
git pull
git tag -a v1.5.0 -m "Release v1.5.0"
git push origin v1.5.0
```

### GitHub Releases

After tagging, create a GitHub Release with auto-generated notes:

```bash
gh release create v1.5.0 --generate-notes
```

Or set up [release-drafter](https://github.com/release-drafter/release-drafter) to draft release notes automatically from merged PR titles.

### Rules

- Tag format: `vMAJOR.MINOR.PATCH` — e.g. `v1.5.0`, never `1.5.0` or `release-1.5.0`.
- First production release is `v1.0.0` — do not ship `v0.x` to production.
- Never re-tag. If a release is broken, ship a new patch (`v1.5.1`).

---

## 9. Promotion Cadence

To avoid surprise deploys and align with QA capacity:

- **development → staging**: on demand, typically end of a sprint or when a milestone is complete. Initiated by the tech lead.
- **staging → main**: scheduled release window, e.g. **every Tuesday at 10:00**, after QA sign-off. Adjust per team but document it.
- **hotfix → main**: as soon as fix + review + CI are complete. No waiting for a window.

---

## 10. Rollback Procedure

If a release breaks production:

1. **Redeploy the previous tag** — do not `git revert` immediately. Keep the bad commits in `main` for debugging.
  ```bash
   # Example: redeploy v1.4.2 to replace broken v1.5.0
   <your deploy command> v1.4.2
  ```
2. Open a `hotfix/` branch to **fix forward** — patch the bug and ship `v1.5.1`.
3. Post-mortem: file a Plane ticket capturing what broke and what guardrail would have caught it.

---

## 11. Repository Files to Set Up

Add these to the repo before opening it up to the team.


| File                                        | Purpose                                               |
| ------------------------------------------- | ----------------------------------------------------- |
| `.github/CODEOWNERS`                        | Auto-request reviewers by code area (§6)              |
| `.github/pull_request_template.md`          | Enforces the PR checklist (§4)                        |
| `.github/ISSUE_TEMPLATE/bug_report.md`      | Standardize bug reports                               |
| `.github/ISSUE_TEMPLATE/feature_request.md` | Standardize feature requests                          |
| `.gitignore`                                | Keep generated files, IDE state, secrets out of git   |
| `.gitattributes`                            | Normalize line endings across macOS / Linux / Windows |
| `CONTRIBUTING.md`                           | Short pointer to this document                        |
| `README.md`                                 | Project overview + setup                              |


---

## 12. Day-to-Day Cheat Sheet

```bash
# Start a new feature
git checkout development
git pull
git checkout -b feature/PROJ-123-add-thing

# Commit work
git add -p
git commit -m "feat(scope): add thing"

# Keep up to date with development while working
git fetch origin
git rebase origin/development

# Push and open a PR
git push -u origin feature/PROJ-123-add-thing
gh pr create --base development --title "feat(scope): add thing" --fill

# After merge — clean up
git checkout development
git pull
git branch -d feature/PROJ-123-add-thing
```

---

## 13. Quick FAQ

**Q: Can I merge my own PR?**
No. Even with required approvals, the merge button is for the reviewer or the tech lead. This prevents accidentally merging before all conversations are resolved.

**Q: Can I push directly to `development` for a tiny fix?**
No. There is no "tiny." Every change goes through a PR so CI runs and history is consistent.

**Q: My PR has been open for days with no review — what do I do?**  
Ping the CODEOWNER directly in the PR or on Discord. If still blocked after 24h, escalate to the tech lead.

**Q: Can I rebase a PR branch after others have started reviewing it?**
Prefer adding fixup commits during review. Squash happens automatically at merge time. Only rebase if you need to pick up changes from `development` to resolve conflicts.

**Q: What goes in `chore/` vs `feature/` vs `refactor/`?**

- `feature/` → user-visible behavior change.
- `bugfix/` → user-visible bug fix.
- `refactor/` (or `chore/`) → no user-visible change; internal cleanup, tooling, deps.

**Q: How do I know what version is currently live?**
Check the latest tag on `main`: `git describe --tags --abbrev=0 origin/main`.