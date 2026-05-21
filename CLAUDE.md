# CLAUDE.md

Flutter app template, Dart `^3.8.1` / Flutter `^3.8.1`. GetX for state/DI/routing, Dio HTTP, flutter_dotenv. Package: `app_structure`. **Authoritative architecture doc:** [docs/PROJECT_ARCHITECTURE.md](docs/PROJECT_ARCHITECTURE.md) — read it before structural changes.

## Commands

All via Makefile (`make help` for the full list).

- **Setup**: `make env-setup` (copy `.env.example` → `.env`; required), then `flutter pub get`.
- **Run**: `make run`. Switch env by editing `EnvironmentType` arg in [lib/main.dart](lib/main.dart) — no `--flavor` / `--dart-define`.
- **Test single file**: `make test-file FILE=test/path_test.dart`. All tests: `make test`.
- **Lint**: `make lint` (`format` + `analyze`). Auto-fix: `make fix`.

## Boot order (don't reorder)

`main.dart`: `await bootstrap()` (loads `.env`) → `AppEnvironment.setEnvironment(...)` → `runApp(const MyApp())`. Reading `AppEnvironment` or `ApiUrls` before bootstrap awaits throws unloaded-dotenv. Single `.env`; active values picked by `EnvironmentType` in code, not flavors.

## Architecture rule (one line)

Per-feature `domain/` (pure Dart interfaces+entities) ← `data/` (impl, DTOs, datasources) ← `presentation/` (views, GetX controllers, bindings). **Controllers never see `Result`/`Failure`/JSON** — repo impl `fold`s and throws, controller `try/catch`es and surfaces via `AppSnackBar`. Two `Result` types exist on purpose: [lib/core/network/](lib/core/network/) (transport) and [lib/core/types/](lib/core/types/) (domain).

## GetX gotchas

- Bindings register **DataSource → Repository → Controller** with `Get.lazyPut`; always register repo as the **interface** (`Get.lazyPut<AuthRepository>(...)`).
- Global services use `Get.put(..., permanent: true)` only in `LazyBinding` inside [lib/app.dart](lib/app.dart).
- Views use `GetView<FooController>`; wrap reactive widgets in `Obx(() => ...)` at the smallest scope.
- **No `BuildContext` across `await` in controllers.** Controllers return `Future<bool>`; views do `if (context.mounted && ok) showDialog(...)`. See `SignInController.onSignIn`.
- Always `dispose()` `TextEditingController`s in `onClose()`.

## Lint quirks (analysis_options.yaml)

`always_use_package_imports` (no relative imports across folders — use `package:app_structure/...`; same-screen relative is fine), `require_trailing_commas`, `prefer_single_quotes`, `avoid_print` (use `debugPrint`), formatter `page_width: 500` and `trailing_commas: preserve`.

## Don'ts

- Don't import `data/` from controllers/views. Import the domain interface; the binding wires the impl.
- Don't put JSON in domain entities. `*_model.dart` in `data/` has `fromJson`/`toEntity()`.
- Don't `Get.put` in screen bindings (use `Get.lazyPut`). Don't `Navigator.of(context)` (use `Get.toNamed`/`back`/`offAllNamed`).
- Don't commit `.env`. Keep `.env.example` in sync.
