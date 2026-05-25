---
alwaysApply: true
---

# Code Quality

## Anti-defaults (counter common Claude tendencies)

- No premature abstractions. Three similar lines beats a helper used once.
- Don't add features or improvements beyond what was asked.
- Don't refactor adjacent code while fixing a bug.
- No dead code or commented-out blocks. Git has history.
- WHY comments, never WHAT. If code needs a "what" comment, rename instead.
- API docs at module boundaries only, not every internal function.

## Design tokens (never inline a literal)

- Colors: use `AppColors.x` — never `Color(0xFF…)` or `Colors.red` etc. in feature/shared code. For brightness-aware surfaces, add both a light and a dark token (`backgroundColor` + `backgroundDark`, etc.) and let `AppTheme._baseTheme.pick(...)` choose.
- Spacing / radius / shadows: use `AppDimensions.spacing*` / `AppDimensions.radius*` / `AppDimensions.*Shadow`, OR the convenience shortcuts in `core/theme/app_style.dart` (`defaultPadding`, `AppRadius.standard`, `AppEdgeInsets.all`). Both APIs are valid — `app_style.dart` is a thin passthrough, not a shim. Never inline raw doubles like `12.h` or `BorderRadius.circular(8)`.
- Text style: use `AppText` widget or `AppTypography.x` tokens — never `TextStyle(fontSize: …, fontWeight: …)` inline.
- UI state: use `ViewState` + `StateSwitch` for loading/empty/error/success branching — never roll a per-screen state enum.
- **Strings (visible to users)**: use `I18n.<key>.tr` (from `lib/core/i18n/i18n_keys.dart`). Never inline a string literal in a `Text(...)`, `AppText(...)`, `hintText:`, `label:`, `title:`, snackbar message, dialog title, etc. Adding a key requires editing `assets/i18n/en.json` (+ each other `<lang>.json`) AND `i18n_keys.dart`. Strings that are not user-visible (log tags, route names, storage keys, JSON field names) stay raw — i18n is for UI copy only.

## Naming (Dart / Flutter)

- Files and directories: `snake_case.dart` (`sign_in_view.dart`, `auth_remote_datasource.dart`). One class per file.
- Classes / enums / typedefs: `PascalCase`. Members / locals / parameters: `lowerCamelCase`. Constants: `lowerCamelCase` too (Dart convention; `constant_identifier_names` is disabled in `analysis_options.yaml`).
- Suffixes are part of the convention: `*View`, `*Controller`, `*Bindings`, `*RepositoryImpl`, `*RemoteDataSource`, `*Model`, `*Request`, `*Response`. Repository interfaces have no suffix beyond `Repository`. There is no entity layer — `*Model` is the type used across data / domain / presentation.
- Controller action methods: `on*` (`onSignIn`, `onVerify`, `onResend`). Validators: `*Validator`. Form keys: `*FormKey`. `TextEditingController` fields: `*Controller`.
- Imports: prefer `package:app_structure/...` over relative imports across folders (enforced by `always_use_package_imports`). Relative is fine **only** within the same screen folder.

## Code Markers

`TODO(author): desc (#issue)` for planned work. `FIXME(author): desc (#issue)` for known bugs. `HACK(author): desc (#issue)` for ugly workarounds (explain the proper fix). `NOTE: desc` for non-obvious context. Owner and issue link required. Never `XXX`, `TEMP`, `REMOVEME`.

## File Organization

- Imports: builtins, external, internal, relative, types. Blank line between groups.
- Exports: named over default. One component or class per file.
- Function order: public API first, then helpers in call order.
