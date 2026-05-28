# CLAUDE.md

Flutter app template, Dart `^3.8.1` / Flutter `^3.8.1`. GetX for state/DI/routing, Dio HTTP, flutter_dotenv. Package: `app_structure`. **Authoritative architecture doc:** [docs/PROJECT_ARCHITECTURE.md](docs/PROJECT_ARCHITECTURE.md) — read it before structural changes.

**Platform floors:** Android `minSdk = 26` (Android 8), iOS deployment target `15.0`. Android toolchain: Gradle `8.14.3`, AGP `8.11.1`, Kotlin `2.2.20`, Java `17`. `flutter_local_notifications` requires core library desugaring (`desugar_jdk_libs` 2.1.4) — already wired in `android/app/build.gradle.kts`. Jetifier is OFF; all plugins must be AndroidX-native.

## Commands

All via Makefile (`make help` for the full list).

- **Setup**: `make env-setup` (copy `.env.example` → `.env`; required), then `flutter pub get`.
- **Run**: `make run`. Switch env by editing `EnvironmentType` arg in [lib/main.dart](lib/main.dart) — no `--flavor` / `--dart-define`.
- **Test single file**: `make test-file FILE=test/path_test.dart`. All tests: `make test`.
- **Lint**: `make lint` (`format` + `analyze`). Auto-fix: `make fix`.

## Boot order (don't reorder)

`main.dart` wraps `runApp` in `runZonedGuarded` and calls `bootstrap(environment: EnvironmentType.development)`. All boot work lives in `bootstrap.dart`: `WidgetsFlutterBinding` → `AppErrorHandler.init()` → `dotenv.load` → `AppEnvironment.setEnvironment` → guarded `Firebase.initializeApp` → system chrome → `InitialBinding().dependencies()` → `LocalStorageService.init()`. Reading `AppEnvironment` or `ApiUrls` before `bootstrap` awaits throws unloaded-dotenv. Firebase init is guarded: missing `google-services.json` / `GoogleService-Info.plist` is logged and boot continues — Crashlytics/Analytics no-op until config is added. Single `.env`; active values picked by `EnvironmentType` in code, not flavors.

## Architecture rule (one line)

Per-feature `domain/` (abstract Repository interface) ← `data/` (datasource calls `ApiClient`, model with `fromJson`/`toJson`, repo impl persists via `SecureStorage`/`LocalStorage`) ← `presentation/` (binding, controller, view). **`*Model` is THE type across all layers — no entity / DTO split.** Controllers depend on the **interface** in `domain/`, never on impl / datasource / `ApiResponse`. Errors travel as `Exception`; UI state travels as `ViewState` via the shared [`StateSwitch`](lib/shared/widgets/state_switch.dart) widget. Full layer contract in [.claude/rules/architecture.md](.claude/rules/architecture.md).

## GetX gotchas

- Global services register in [`lib/core/di/initial_binding.dart`](lib/core/di/initial_binding.dart). **Permanent** (survive logout): storage, telemetry (Crashlytics + Analytics), connectivity, deep-link + notification, i18n (`AppTranslations`, `LocaleController`), `ThemeController`, `AuthController`. **Lazy + fenix**: `AppInfoService`, `PermissionService`, `DeviceInfoService`, `ApiClient`, `AuthRemoteDataSource`, `AuthRepositoryImpl`.
- Feature controllers extend [`BaseController`](lib/core/base/base_controller.dart) (`state`, `errorMessage`, `runGuarded<T>`) — cuts ~10 LOC per `on*` action. Plain `GetxController` only when there's no async state machine.
- Screen `Bindings` register `DataSource → Repository → Controller` with `Get.lazyPut`; always register repo as the **interface** (`Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(...))`).
- Views use `GetView<FooController>`; render data branches via `StateSwitch` reading `controller.state.value`. Wrap reactive widgets in `Obx(() => ...)` at the smallest scope.
- **No `BuildContext` across `await` in controllers.** Controllers return `Future<bool>`; views do `if (context.mounted && ok) showDialog(...)`. See `LoginController.onLogin`.
- Always `dispose()` `TextEditingController`s in `onClose()`.

## i18n + theme

- Every visible string goes through `I18n.<key>.tr` (`lib/core/i18n/i18n_keys.dart`). Adding a key edits each `assets/i18n/<lang>.json` AND `i18n_keys.dart`. Switch language via `Get.find<LocaleController>().setLocale(...)`.
- Theme switches via `Get.find<ThemeController>().setMode(ThemeMode.dark/light/system)`. `AppTheme._baseTheme` is brightness-aware — adding a new themed surface requires both light + dark tokens in `AppColors`.

## Errors + logging

- Uncaught errors are captured by `AppErrorHandler` (FlutterError, PlatformDispatcher, runZonedGuarded) and routed through `AppLogger.error` → `errorReportHook` → Crashlytics (when wired).
- In code, call `AppLogger.{debug, info, success, warning, error, data}` — never `print()`. `AppLogger.error(msg, error: e, stackTrace: st, tag: '...')` is the canonical error log.

## Lint quirks (analysis_options.yaml)

`always_use_package_imports` (no relative imports across folders — use `package:app_structure/...`; same-screen relative is fine), `require_trailing_commas`, `prefer_single_quotes`, `avoid_print` (use `debugPrint`), formatter `page_width: 500` and `trailing_commas: preserve`.

## Don'ts

- Don't import `data/` from controllers/views. Import the domain interface; the binding wires the impl.
- Don't add an entity / DTO split. `*Model` (in `data/`) is THE type across all layers, with `fromJson` / `toJson` / `copyWith`. Domain holds only the abstract Repository interface and references the `*Model` types from `data/`.
- Don't `Get.put` in screen bindings (use `Get.lazyPut`). Don't `Navigator.of(context)` (use `Get.toNamed`/`back`/`offAllNamed`).
- Don't inline user-visible strings — use `I18n.<key>.tr`. Don't inline colors / sizes — use `AppColors` / `AppDimensions`.
- Don't navigate from `NotificationService` or `DeepLinkService` — subscribe to their streams and navigate from a top-level coordinator.
- Don't create a second implementation of something that already exists. One job, one home: validators live only in `ValidationMixin`, tokens in `core/theme/`, platform wrappers in `core/services/`. Extend the canonical version — never fork a near-copy. See [.claude/rules/code-quality.md](.claude/rules/code-quality.md) "No duplicate implementations".
- Don't commit `.env`. Keep `.env.example` in sync.
