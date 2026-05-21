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

## Naming (Dart / Flutter)

- Files and directories: `snake_case.dart` (`sign_in_view.dart`, `auth_remote_datasource.dart`). One class per file.
- Classes / enums / typedefs: `PascalCase`. Members / locals / parameters: `lowerCamelCase`. Constants: `lowerCamelCase` too (Dart convention; `constant_identifier_names` is disabled in `analysis_options.yaml`).
- Suffixes are part of the convention: `*View`, `*Controller`, `*Bindings`, `*RepositoryImpl`, `*RemoteDataSource`, `*Model`. Repository interfaces have no suffix beyond `Repository`.
- Controller action methods: `on*` (`onSignIn`, `onVerify`, `onResend`). Validators: `*Validator`. Form keys: `*FormKey`. `TextEditingController` fields: `*Controller`.
- Imports: prefer `package:app_structure/...` over relative imports across folders (enforced by `always_use_package_imports`). Relative is fine **only** within the same screen folder.

## Code Markers

`TODO(author): desc (#issue)` for planned work. `FIXME(author): desc (#issue)` for known bugs. `HACK(author): desc (#issue)` for ugly workarounds (explain the proper fix). `NOTE: desc` for non-obvious context. Owner and issue link required. Never `XXX`, `TEMP`, `REMOVEME`.

## File Organization

- Imports: builtins, external, internal, relative, types. Blank line between groups.
- Exports: named over default. One component or class per file.
- Function order: public API first, then helpers in call order.
