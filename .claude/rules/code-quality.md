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

## No duplicate implementations (one job, one home)

If a file, class, function, or widget already does the work, **reuse or extend it — never create a second thing that does the same job.** Two implementations of one concept always drift apart and one silently goes stale (we shipped a static `Validators` class AND a `ValidationMixin` with subtly different password rules; validation now lives only in `core/mixins/validation_mixin.dart`).

- Before adding anything, search the tree for an existing equivalent (`grep` the symbol / concept). Found one? Extend it — add a parameter or method, don't fork a near-copy.
- Each concept has exactly one canonical home:
  - Form validators → `core/mixins/validation_mixin.dart` (mix into the controller). There is **no** static `Validators` class.
  - Design tokens → `core/theme/` (colors, spacing/radius, typography). Never inline a literal.
  - User-visible strings → `core/i18n/`.
  - Platform-capability wrappers (pickers, FCM, downloads, permissions) → `core/services/`.
  - Pure string / number / date helpers → `core/utils/`.
- Deleting the old copy is part of the change — a "temporary" second implementation is still a duplicate.
- If two existing things already overlap, consolidate them into one and remove the loser; don't add a third.

## Commenting

The skeleton has a single consistent comment style. Follow it on every file you touch.

**Always add:**

1. **Class / top-level function docstring** — one paragraph on purpose + when to use, plus a short usage example in a ```dart` fence. This is the only doc a future reader needs to understand what the file is for.
2. **WHY comments** — non-obvious behaviour the code can't express on its own: ordering constraints ("don't reorder this boot step"), hidden invariants, security guarantees, workarounds for specific bugs, footguns.
3. **Public API docs at module boundaries** — services, repositories, base classes, shared widgets exported across features. Anything other modules import.

**Don't add:**

1. **WHAT comments that restate the name** — `spacing16` doesn't need `/// 16 logical px.`, `final String label;` doesn't need `/// The label.`, `void onLogin()` doesn't need `/// Called when the user logs in.` If the name carries the meaning, no comment.
2. **Per-member docs on scale tokens, enum values, or simple DTO fields** — the class docstring is the contract; individual entries are self-describing.
3. **Per-method WHAT docs on internal helpers** — private methods, build helpers, and per-screen one-offs. Keep the code clean.
4. **Author / date / "added by X" stamps** — `git blame` / `git log` are authoritative.
5. **Section dividers without payload** — `// ───── public API ─────` is fine only if it groups ≥3 related items.

**Concrete before / after**

```dart
// ❌ Per-member WHAT noise
abstract class AppDimensions {
  /// 12 logical px.
  static const double spacing12 = 12;

  /// 16 logical px.
  static const double spacing16 = 16;
}

// ✅ Class docstring carries the meaning, names are self-describing
/// Spacing scale. Use over inline literals so the whole app moves
/// together when the scale is retuned.
abstract class AppDimensions {
  static const double spacing12 = 12;
  static const double spacing16 = 16;
}
```

```dart
// ❌ Restating the field name
class AppButton extends StatefulWidget {
  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// The label of the button.
  final String? label;
}

// ✅ Class doc handles the surface; fields speak for themselves
/// Primary button with elevated / outlined / gradient variants.
class AppButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String? label;
}
```

```dart
// ✅ WHY comment that earns its keep
// Firebase init guarded — missing google-services.json / GoogleService-Info.plist
// is logged and boot continues. Crashlytics + Analytics no-op until config lands.
try { await Firebase.initializeApp(); } on Object catch (e) { ... }
```

## Design tokens (never inline a literal)

- Colors: use `AppColors.x` — never `Color(0xFF…)` or `Colors.red` etc. in feature/shared code. For brightness-aware surfaces, add both a light and a dark token (`backgroundColor` + `backgroundDark`, etc.) and let `AppTheme._baseTheme.pick(...)` choose.
- Spacing / radius / shadows: use `AppDimensions.spacing*` / `AppDimensions.radius*` / `AppDimensions.*Shadow`, OR the convenience shortcuts in `core/theme/app_dimensions.dart` (`defaultPadding`, `AppRadius.standard`, `AppEdgeInsets.all`). Both APIs are valid — the shortcuts resolve to scale tokens internally. Never inline raw doubles like `12.h` or `BorderRadius.circular(8)`.
- Text style: use `AppText` widget or `AppTypography.x` tokens — never `TextStyle(fontSize: …, fontWeight: …)` inline.
- UI state: use `ViewState` + `StateSwitch` for loading/empty/error/success branching — never roll a per-screen state enum.
- **Strings (visible to users)**: use `I18n.<key>.tr` (from `lib/core/i18n/i18n_keys.dart`). Never inline a string literal in a `Text(...)`, `AppText(...)`, `hintText:`, `label:`, `title:`, snackbar message, dialog title, etc. Adding a key requires editing `assets/i18n/en.json` (+ each other `<lang>.json`) AND `i18n_keys.dart`. Strings that are not user-visible (log tags, route names, storage keys, JSON field names) stay raw — i18n is for UI copy only.

## Naming (Dart / Flutter)

- Files and directories: `snake_case.dart` (`sign_in_view.dart`, `auth_remote_datasource.dart`). One class per file.
- Classes / enums / typedefs: `PascalCase`. Members / locals / parameters: `lowerCamelCase`. Constants: `lowerCamelCase` too (Dart convention; `constant_identifier_names` is disabled in `analysis_options.yaml`).
- Suffixes are part of the convention: `*View`, `*Controller`, `*Bindings`, `*RepositoryImpl`, `*RemoteDataSource`, `*Model`, `*Request`, `*Response`. Repository interfaces have no suffix beyond `Repository`. There is no entity layer — `*Model` is the type used across data / domain / presentation.
- Controller action methods: `on*` (`onSignIn`, `onVerify`, `onResend`). Validators: `*Validator`, all defined in `ValidationMixin` (mix it into the controller — there is no static `Validators` class). Form keys: `*FormKey`. `TextEditingController` fields: `*Controller`.
- Imports: prefer `package:app_structure/...` over relative imports across folders (enforced by `always_use_package_imports`). Relative is fine **only** within the same screen folder.

## Code Markers

`TODO(author): desc (#issue)` for planned work. `FIXME(author): desc (#issue)` for known bugs. `HACK(author): desc (#issue)` for ugly workarounds (explain the proper fix). `NOTE: desc` for non-obvious context. Owner and issue link required. Never `XXX`, `TEMP`, `REMOVEME`.

## File Organization

- Imports: builtins, external, internal, relative, types. Blank line between groups.
- Exports: named over default. One component or class per file.
- Function order: public API first, then helpers in call order.
