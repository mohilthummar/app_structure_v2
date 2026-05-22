# `.claude/` Folder Guide

Single-page reference for what lives in `.claude/`, what loads when, and which file to edit when the project's conventions change.

**Authoritative design spec:** [docs/superpowers/specs/2026-05-21-skeleton-update-from-happypet-design.md](superpowers/specs/2026-05-21-skeleton-update-from-happypet-design.md)
**Architecture summary:** [docs/PROJECT_ARCHITECTURE.md](PROJECT_ARCHITECTURE.md)

## What is `.claude/`?

A per-project configuration directory checked into git so every developer working with Claude Code on this repo gets the same:

- **Permissions** — which shell commands Claude is allowed to run without asking
- **Hooks** — shell scripts that fire on tool events (before/after Edit, before Bash, on session start, on notification)
- **Rules** — short Markdown files Claude loads automatically when working near matching paths
- **Agents** — specialist personas (code reviewer, security reviewer, etc.) Claude can delegate to in isolated context
- **Skills** — invocable workflows (`/tdd`, `/ship`, `/refactor`, …) the user triggers by slash command

The root-level `CLAUDE.md` is the always-loaded project brief. Everything else in `.claude/` loads conditionally (per matched path) or on-demand (per invocation), so the per-turn token cost stays low.

## Folder tree

```
.claude/
├── settings.json                 Flutter-tuned permissions + hook wiring
├── agents/                       Invoked-only specialists (run in isolated context)
│   ├── code-reviewer.md
│   ├── security-reviewer.md
│   ├── performance-reviewer.md
│   ├── doc-reviewer.md
│   └── frontend-designer.md
├── hooks/                        Shell scripts triggered by tool events
│   ├── session-start.sh          SessionStart  — emits branch + dirty indicator
│   ├── context-recovery.sh       SessionStart  — re-injects rules after compaction
│   ├── protect-files.sh          PreToolUse    — blocks edits to .env / secrets / hook scripts
│   ├── warn-large-files.sh       PreToolUse    — blocks writes into build dirs
│   ├── scan-secrets.sh           PreToolUse    — scans content for leaked keys
│   ├── block-dangerous-commands  PreToolUse    — blocks force push, rm -rf, etc.
│   ├── format-on-save.sh         PostToolUse   — runs dart format / prettier / ...
│   ├── auto-test.sh              PostToolUse   — runs the matching test file
│   ├── notify.sh                 Notification  — OS-native toast on attention
│   └── tests/                    fixtures + run-all.sh for hook unit tests
├── rules/                        Project conventions loaded by path
│   ├── architecture.md
│   ├── code-quality.md
│   ├── testing.md
│   ├── error-handling.md
│   └── security.md
└── skills/                       Slash-command workflows
    ├── setupdotclaude/SKILL.md
    ├── tdd/SKILL.md
    ├── debug-fix/SKILL.md
    ├── refactor/SKILL.md
    ├── ship/SKILL.md
    ├── explain/SKILL.md
    ├── test-writer/SKILL.md
    ├── pr-review/SKILL.md
    └── context-budget/SKILL.md
```

## `settings.json`

**Permissions — allow list.** Pre-approved so Claude never prompts for them:

- `flutter pub *`, `flutter run *`, `flutter test *`, `flutter analyze [*]`, `flutter build *`, `flutter clean`, `flutter doctor [*]`, `flutter devices`, `flutter logs`, `flutter --version`
- `dart format *`, `dart fix *`, `dart --version`
- `make *` (entire Makefile is allowed — `make run`, `make test`, `make verify`, etc.)
- `git status / diff / log / branch / stash / add / commit / fetch / checkout / switch`
- `gh pr *`, `gh issue *`, `gh run *`

**Permissions — deny list.** Hard-blocked from Read/Write/Edit regardless of permission mode:

- `**/.env`, `**/.env.*`
- `**/secrets/**`
- `**/*.pem`, `**/*.key`

**Hook wiring.** Defined under `"hooks"`:

| Event | Matcher | Hook scripts (run in order) |
|---|---|---|
| `PreToolUse` | `Edit\|Write` | `protect-files.sh` → `warn-large-files.sh` → `scan-secrets.sh` |
| `PreToolUse` | `Bash` | `block-dangerous-commands.sh` |
| `PostToolUse` | `Edit\|Write` | `format-on-save.sh` |
| `SessionStart` | (any) | `session-start.sh` |
| `Notification` | (any) | inline `osascript` / `notify-send` fallback (`notify.sh` is also available) |

Edit when: a new tool is added to the project's daily loop (e.g. `melos`, `fastlane`), a new sensitive path needs locking, or a new hook event needs wiring.

Note: `protect-files.sh` itself blocks edits to `.claude/hooks/**` — so changing any hook script requires either temporarily disabling that rule or editing the file outside Claude Code.

## `rules/` — Project conventions

Markdown files loaded automatically based on the `paths:` glob in their frontmatter (no frontmatter = always loaded).

| File | When it loads | Enforces |
|---|---|---|
| `architecture.md` | Always (no `paths:` frontmatter) | Boot order (`bootstrap` → `AppEnvironment` → `InitialBinding` → `LocalStorage.init` → `runApp`), per-feature layer contract (`domain/` interface ← `data/` impl ← `presentation/` controller+view+binding), DI strategy (`Get.put(..., permanent: true)` for storage + `AuthController`; `Get.lazyPut(..., fenix: true)` everything else), routing (`RouteNames` + `AppPages` + `AuthMiddleware`), network stack (one `ApiClient`, `AuthInterceptor`, single-flight `TokenRefreshInterceptor`), UI state (`ViewState` + `StateSwitch`). |
| `code-quality.md` | Always | Anti-default rules (no premature abstractions, WHY-only comments, no commented-out code), design-token discipline (no inline `Color`, raw doubles, inline `TextStyle`), Dart/Flutter naming (`snake_case.dart`, `*View`, `*Controller`, `*Bindings`, `*RepositoryImpl`, `*RemoteDataSource`, `*Model`), import rules (`package:app_structure/...` across folders), code markers (`TODO(author): … (#issue)`). |
| `testing.md` | Always | Behavior over implementation, run the specific test file, mock the `domain/` repository interface (not impl / datasource / `ApiClient`), `mocktail` (no codegen), reset GetX between tests via `Get.testMode = true` + `Get.reset()` (helper in `test/_helpers/test_bootstrap.dart`), controller tests instantiate controllers directly, repo-impl tests `verify` storage side effects. |
| `error-handling.md` | `paths: lib/features/**/data/**`, `lib/features/**/presentation/**`, `lib/core/network/**`, `lib/core/controllers/**` | Layered errors: DataSource throws on `!response.success`; Repo impl `try/catch` + rethrow + storage side-effects; Controller sets `state = ViewState.error` + `errorMessage`; View branches via `StateSwitch`. Never silently swallow (allowed exceptions: `AuthRepositoryImpl.logout`, `AuthController.logout`). No `BuildContext` across `await`. Tokens only in `SecureStorageService`. |
| `security.md` | `paths: lib/features/auth/**`, `lib/core/network/**`, `lib/core/storage/**`, `lib/core/services/**`, `lib/core/config/**` | Never commit `.env`. Tokens through Dio headers via `SecureStorageService` (never URLs / `LocalStorageService`). Validate JSON in `fromJson` before constructing models. Whitelist deep-link routes and push payload shapes. MIME / size / extension checks before file upload. Narrowest `permission_handler` request. Map `DioException` to user-safe strings. Allowlist URL schemes before `url_launcher`. |

Edit when: a convention changes. For example, if `AuthController` moves out of permanent DI, update `architecture.md`. If a new sensitive path is added to `lib/`, extend the `paths:` frontmatter on `security.md` and `error-handling.md`.

## `agents/` — Invoked-only specialists

Run in isolated context (their prompt cost is per-invocation in their own session, not per-turn in the main thread). Invoke via `Task` tool with `subagent_type: <name>`, or let `/pr-review` fan them out in parallel.

| Agent | Use when | Tools |
|---|---|---|
| `code-reviewer` | Diff review, PR review, post-change verification. Universal correctness pass. | Read, Grep, Glob, Bash |
| `security-reviewer` | Auth, input handling, queries, tokens, session management, file path construction. Static-analysis only. | Read, Grep, Glob, Bash |
| `performance-reviewer` | Endpoints, queries, hot loops, caching, connection management. Cost-model based (frequency × per-call cost). | Read, Grep, Glob, Bash |
| `doc-reviewer` | `.md` changes, docstring changes, API docs. Cross-references docs against source. | Read, Grep, Glob, Bash |
| `frontend-designer` | Scaffolding a screen / refining a widget / auditing a view. Flutter-specific: enforces `AppColors`, `AppDimensions`, `AppTypography`, `ViewState` + `StateSwitch`, `GetView<Controller>`. | Read, Write, Edit, Bash, Glob, Grep |

All agents apply a ≥80% confidence filter and default to terse output (one line per finding). Append `verbose` to the invocation prompt for the full multi-field breakdown.

Edit when: a new specialist persona is needed for this project (e.g. an `accessibility-reviewer` once a11y rules harden), or when an existing agent's examples drift from the project's tech stack.

## `hooks/` — Tool-event scripts

Silent on success by design — zero per-turn token cost unless a hook actually blocks or warns.

| Hook | Event | Behavior |
|---|---|---|
| `session-start.sh` | `SessionStart` | Echoes `Branch: <name> \| dirty` (minimal). Set `DOTCLAUDE_SESSION_VERBOSE=1` for last commit + file count + staged + stash + PR info. |
| `context-recovery.sh` | `SessionStart` (matcher `compact`) | After context compaction, re-injects the critical project rules and re-reads `CLAUDE.md` so summary-induced drift is corrected. |
| `protect-files.sh` | `PreToolUse: Edit\|Write` | Blocks writes to `.env*`, `*.pem`, `*.key`, `*.crt`, `*.p12`, `*.pfx`, `id_rsa`, `id_ed25519`, `credentials.json`, `.npmrc`, `.pypirc`, lock files, `*.gen.*`, `*.min.*`, `.git/**`, `secrets/**`, `.claude/hooks/**`. Asks for confirmation on `.claude/settings*.json`. |
| `warn-large-files.sh` | `PreToolUse: Edit\|Write` | Blocks writes into `node_modules/`, `vendor/`, `dist/`, `build/`, `.next/`, `__pycache__/`, `.venv/`, `venv/`, `.dart_tool/`, `ios/Pods/`, `android/.gradle/`. Blocks writes to binary / archive / media / bytecode files. |
| `scan-secrets.sh` | `PreToolUse: Edit\|Write` | Scans `tool_input.content` / `new_string` for AWS keys, GitHub tokens, OpenAI / Stripe / Anthropic `sk-…` keys, Slack tokens, PEM private-key blocks, DB connection strings with embedded creds, hardcoded password / secret / token / api_key literals. Emits `ask` (not `deny`) so test fixtures can be allowed through deliberately. |
| `block-dangerous-commands.sh` | `PreToolUse: Bash` | Blocks: push to protected branches (`main`, `master`, `init.defaultBranch`, `CLAUDE_PROTECTED_BRANCHES`), force push (allows `--force-with-lease`), `rm -rf /`, `rm -rf ~`, `rm -rf /usr` (and friends), `DROP TABLE/DATABASE/SCHEMA`, `DELETE FROM` without `WHERE`, `TRUNCATE TABLE`, `chmod 777 / a+rwx`, `curl \| sh`, `> /dev/<device>`, `mkfs`, `dd if=/dev/...`, `git reset --hard`, `git clean -f*`, package publishes (`npm/yarn/pnpm/bun publish`, `cargo publish`, `gem push`, `twine upload`) without `--dry-run`. |
| `format-on-save.sh` | `PostToolUse: Edit\|Write` | Auto-detects formatter from project root manifest. For this project: `pubspec.yaml` present → `dart format <file>`. Also supports Biome, Prettier, Ruff, Black + isort, rustfmt, gofmt for mixed repos. |
| `auto-test.sh` | `PostToolUse: Edit\|Write` | If the edited file has a matching `*_test.dart` under `test/` (mirroring `lib/`), runs `flutter test <test-file>`. Silent unless the test fails. Skips test files, config files, and non-code extensions. |
| `notify.sh` | `Notification` (also wired inline in settings.json) | Native OS toast — `osascript` (macOS), `notify-send` (Linux), `powershell.exe` (WSL). |
| `tests/run-all.sh` + `tests/fixtures/` | Manual | Hook unit-test harness — feeds each fixture JSON into the matching hook and asserts on `permissionDecision`. Run with `bash .claude/hooks/tests/run-all.sh`. |

Edit when: a new dangerous pattern is observed in the wild, a new sensitive directory needs locking, or the formatter / test runner changes. Note that `protect-files.sh` blocks Claude from editing any file under `.claude/hooks/` — update those manually.

## `skills/` — Slash-command workflows

Invoked by `/<name>` (or by Claude proactively if the skill's frontmatter lacks `disable-model-invocation: true`). Zero per-turn cost.

| Skill | Auto-invocable | Purpose | Argument hint |
|---|---|---|---|
| `setupdotclaude` | No | Bootstrap `.claude/` from template and customize for the stack. | `[focus area]` |
| `tdd` | No | Strict red → green → refactor loop. | `[feature description]` |
| `debug-fix` | No | Reproduce / investigate / fix / verify. `--fast` for hotfix-grade emergencies. allowed-tools wired to `flutter test *`, `flutter analyze *`, `make *`. | `[issue or description] [--fast?]` |
| `refactor` | No | Behavior-preserving change with test-coverage safety net. | `[target]` |
| `ship` | No | Scan → stage → commit → push → PR, confirming at each step. | `[optional commit / PR title]` |
| `explain` | No | One-sentence summary + mental model (default). Add `verbose` for diagram + key details + modification guide. | `[target] [verbose?]` |
| `test-writer` | **Yes** | Discovers what changed, maps every code path (happy / edge / null / error / async), writes the tests, verifies. | (auto-discovers) |
| `pr-review` | No | Fans out to `code-reviewer` / `security-reviewer` / `performance-reviewer` / `doc-reviewer` in parallel, synthesizes a unified report. | `[PR# \| staged \| file path]` |
| `context-budget` | No | Estimates per-turn token cost of `CLAUDE.md` + `.claude/`. `--api` for exact counts via Anthropic's `count_tokens` endpoint. | `[--api?]` |

Edit when: the skill's commands drift (e.g. Makefile target renamed), a project-specific workflow emerges that's worth a `/command`, or you want to disable auto-invocation on `test-writer`.

## Token budget at a glance

| Category | Per-turn cost | Files |
|---|---|---|
| Always-loaded | Loads on every turn | `CLAUDE.md`, `rules/architecture.md`, `rules/code-quality.md`, `rules/testing.md` |
| Path-scoped | Loads only when working near matched globs | `rules/error-handling.md`, `rules/security.md` |
| Invoked-only | Zero per-turn cost | All `skills/*/SKILL.md`, all `agents/*.md`, all `hooks/*.sh` (the hooks themselves never load — only their stdout if any) |

Run `/context-budget` for actual counts. Target: total always-loaded under 1000 tokens, hard cap 1500. `CLAUDE.md` itself stays under 25 non-blank lines (hard cap 50).

## Maintenance rules

- **Architectural changes** → update both `.claude/rules/architecture.md` AND `docs/PROJECT_ARCHITECTURE.md` in the same commit.
- **Convention changes** → update the relevant `rules/*.md` file and (if it changes paths) the `paths:` frontmatter glob.
- **Permission / hook changes** → update `.claude/settings.json` AND, if the hook is non-trivial, add a fixture under `.claude/hooks/tests/fixtures/<hook-name>/`. Hook scripts themselves must be edited manually (the protect-files hook blocks Claude from changing them).
- **Agent / skill changes** → only edit one agent or skill at a time; keep them shaped like their siblings (frontmatter, sections, terse-by-default output).
- **Never commit** `.env`, `*.pem`, `*.key`, `credentials.json`, or anything matched by `protect-files.sh`. The deny list in `settings.json` is the second line of defense.

## When to regenerate this doc

Re-run after any of:

- Adding / removing / renaming an agent, hook, rule, or skill
- Changing `settings.json` permissions or hook wiring
- Bumping the design-token discipline (new `AppDimensions` / `AppColors` / `AppTypography` field treated as a convention)
- A new `rules/*.md` file with non-trivial `paths:` scope

Quick test for staleness: `find .claude -type f -newer docs/CLAUDE_FOLDER.md`. If that prints anything, this doc needs a refresh.
