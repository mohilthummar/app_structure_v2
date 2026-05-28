# Project Architecture

The long-form companion to [.claude/rules/architecture.md](../.claude/rules/architecture.md). Read the rule file first for the one-page TL;DR; this doc fills in the why.

---

## Contents

1. [Architecture overview](#1-architecture-overview)
2. [Folder structure](#2-folder-structure)
3. [Boot flow](#3-boot-flow)
4. [Layer contract](#4-layer-contract)
5. [Naming conventions](#5-naming-conventions)
6. [Data flow (Login)](#6-data-flow-login)
7. [Code shape — Auth feature](#7-code-shape--auth-feature)
8. [BaseController](#8-basecontroller)
9. [Errors](#9-errors)
10. [Dependency injection](#10-dependency-injection)
11. [Routing](#11-routing)
12. [Network](#12-network)
13. [UI state (ViewState + StateSwitch)](#13-ui-state-viewstate--stateswitch)
14. [i18n](#14-i18n)
15. [Theming](#15-theming)
16. [Telemetry (Crashlytics + Analytics)](#16-telemetry-crashlytics--analytics)
17. [Notifications + deep links](#17-notifications--deep-links)
18. [Permissions](#18-permissions)
19. [Connectivity](#19-connectivity)
20. [Logging](#20-logging)
21. [Adding a new feature](#21-adding-a-new-feature)
22. [Adding a new screen to an existing feature](#22-adding-a-new-screen-to-an-existing-feature)
23. [Starting a new project from this skeleton](#23-starting-a-new-project-from-this-skeleton)

---

## 1. Architecture overview

Simplified clean architecture, feature-first, GetX for state + DI + routing.

**Layers:**

```
Presentation ──depends on──> Domain <──implements── Data
                                |
                       depends on NOTHING beyond
                       Dart SDK + `*Model` types in `data/`
```

**Key rules:**

- One pattern for every feature — no mixing.
- Domain holds only the abstract `Repository` interface. No use cases.
- Data implements the interface, owns `fromJson`/`toJson`, persists tokens/profile via storage services.
- Presentation has `view + controller + bindings` per screen. Controllers extend `BaseController`.
- `*Model` is THE type across all layers — no entity/DTO split.
- Errors travel as `Exception`; UI state travels as `ViewState` via `StateSwitch`.

---

## 2. Folder structure

```
lib/
├── main.dart                                Entry: runZonedGuarded + bootstrap + runApp
├── bootstrap.dart                           All boot steps (single source of truth)
├── app.dart                                 GetMaterialApp + observers + locale + theme wiring
│
├── core/
│   ├── base/
│   │   └── base_controller.dart            state/errorMessage/runGuarded
│   ├── config/
│   │   ├── app_environment.dart            EnvironmentType, baseUrl, feature flags
│   │   └── api_urls.dart                   Endpoint paths read from .env
│   ├── constants/
│   │   ├── app_assets.dart
│   │   ├── app_colors.dart                 Light AND dark tokens
│   │   ├── app_constants.dart              Timeouts, page sizes, header names, storage keys
│   │   └── constants.dart                  Barrel
│   ├── controllers/
│   │   ├── auth_controller.dart            Session state, login/logout, telemetry hook
│   │   ├── connectivity_controller.dart    isOnline.obs
│   │   ├── locale_controller.dart          setLocale + persistence
│   │   └── theme_controller.dart           setMode + persistence
│   ├── di/
│   │   └── initial_binding.dart            All DI wiring
│   ├── enums/
│   │   ├── common_enums.dart
│   │   ├── environment_enums.dart
│   │   ├── view_state.dart                 idle/loading/success/error/empty
│   │   └── enums.dart                      Barrel
│   ├── error/
│   │   └── app_error_handler.dart          FlutterError + PlatformDispatcher + Zone wiring
│   ├── extensions/
│   ├── i18n/
│   │   ├── app_translations.dart           Extends GetX Translations; loads JSON
│   │   └── i18n_keys.dart                  Typed constants
│   ├── mixins/
│   │   └── validation_mixin.dart           ALL form validators (single source — no static Validators class)
│   ├── network/
│   │   ├── api_client.dart                 One Dio per app
│   │   ├── api_response.dart               Transport envelope (data layer only)
│   │   ├── auth_interceptor.dart           Bearer + CSRF
│   │   └── token_refresh_interceptor.dart  Single-flight 401 refresh
│   ├── routing/
│   │   ├── app_pages.dart                  GetPage list
│   │   ├── auth_middleware.dart            GetMiddleware
│   │   └── route_names.dart                Route name constants
│   ├── services/
│   │   ├── analytics_service.dart          Firebase Analytics wrapper
│   │   ├── app_info_service.dart           package_info_plus wrapper
│   │   ├── crashlytics_service.dart        Firebase Crashlytics wrapper
│   │   ├── deep_linking_manager.dart       DeepLinkService — whitelist-validated
│   │   ├── device_info_service.dart        Device id + FCM token persistence
│   │   ├── fcm_token_service.dart          Static FCM-token fetch (iOS APNS timing)
│   │   ├── file_download_service.dart      Dio download + safe path/scheme handling
│   │   ├── file_picker_service.dart        Static file picker + size/type helpers
│   │   ├── image_picker_service.dart       Static image picker + ImageSourceSheet
│   │   ├── notification_services.dart      FCM + local notifications + whitelist
│   │   └── permission_service.dart         permission_handler wrapper
│   ├── storage/
│   │   ├── local_storage.dart              GetStorage (locale + theme + device info + cached user)
│   │   └── secure_storage.dart             flutter_secure_storage (tokens only)
│   ├── theme/
│   │   ├── app_dimensions.dart             Spacing / radius / shadows
│   │   ├── app_style.dart                  Convenience shortcuts (defaultPadding, AppRadius, AppEdgeInsets)
│   │   ├── app_text.dart                   AppText widget
│   │   ├── app_theme.dart                  Brightness-aware ThemeData
│   │   └── app_typography.dart             Text-style tokens
│   └── utils/                              Stateless helpers (pickers/FCM live in services/, validators in mixins/)
│       ├── app_logger.dart                 debug/info/.../error with Crashlytics hook
│       ├── app_loader.dart, app_snack_bar.dart, app_shimmers.dart, ...
│       ├── formatters/                      Input formatters (currency, phone, ...)
│       └── string_utils.dart               prettyType — snake/camelCase → Title Case
│
├── shared/
│   ├── models/                             Shared DTOs
│   ├── widgets/
│   │   ├── state_switch.dart              ViewState → builder
│   │   ├── offline_banner.dart            ConnectivityController-aware
│   │   └── app_button.dart, app_text_field.dart, ...
│   └── packages/                           Self-contained third-party-style helpers
│
└── features/
    ├── auth/
    │   ├── domain/
    │   │   └── auth_repository.dart        Interface ONLY
    │   ├── data/
    │   │   ├── user_model.dart             fromJson/toJson/copyWith — THE type
    │   │   ├── login_request.dart, login_response.dart
    │   │   ├── auth_remote_datasource.dart
    │   │   └── auth_repository_impl.dart
    │   └── presentation/
    │       ├── splash/, login/, forgot_password/
    │       └── shared/otp_dialog.dart
    └── home/
        ├── domain/home_repository.dart
        ├── data/
        │   ├── dashboard_item_model.dart
        │   ├── home_remote_datasource.dart
        │   └── home_repository_impl.dart
        └── presentation/
            ├── dashboard/                  Demonstrates paginated StateSwitch
            └── profile/                    Theme + language switchers + logout
```

---

## 3. Boot flow

See [.claude/rules/architecture.md](../.claude/rules/architecture.md) for the canonical 11-step list.

The boot seam is `bootstrap.dart`. `main.dart` only wraps `runApp` in `runZonedGuarded` and forwards to `bootstrap`. Every step has a reason to be where it is — don't reorder.

---

## 4. Layer contract

### Domain

| Rule | Detail |
|---|---|
| Contains | The abstract `<Feature>Repository` interface. That's it. |
| May import | Dart SDK, `*Model` types from the same feature's `data/`, `core/` types that are pure (`ViewState` enums etc.). |
| Must NOT import | Flutter, GetX, Dio, `core/network/`, presentation, other features' internals. |
| Returns | `Future<Model>` or `Future<void>` — domain never sees `ApiResponse` / `Result` / `Failure`. |

### Data

| Rule | Detail |
|---|---|
| Contains | `*Model` (with `fromJson`/`toJson`/`copyWith`), `*RemoteDataSource`, `*RepositoryImpl`. |
| May import | Same feature's domain, `core/*`. |
| Must NOT import | Other features' data, presentation. |
| Responsibility | Datasource throws on `!response.success`. Repo impl wraps in `try/catch`, persists side effects (tokens, profile), rethrows as `Exception(e.toString())`. |

### Presentation

| Rule | Detail |
|---|---|
| Contains | Views, controllers (extend `BaseController`), bindings (the only place that imports `data/`). |
| May import | Same feature's domain, `core/*`, `shared/*`, GetX, Flutter. |
| Must NOT import | Data layer directly except in bindings. |
| Responsibility | Controllers handle state via `runGuarded`; views branch via `StateSwitch`. |

---

## 5. Naming conventions

| Type | Pattern | Example |
|---|---|---|
| Folder | `snake_case` | `features/auth/presentation/login/` |
| File | `snake_case.dart` | `login_controller.dart`, `auth_remote_datasource.dart` |
| Class | `PascalCase` + suffix | `LoginController`, `AuthRepositoryImpl`, `UserModel`, `LoginRequest`, `LoginResponse` |
| Repo interface | `<Feature>Repository` | `AuthRepository`, `HomeRepository` |
| Function | camelCase | `getDashboard`, `applyLoginResponse` |
| Controller action | `on<Verb>` | `onLogin`, `onSend`, `onRefresh` |
| Validator | `<field>Validator` (in `ValidationMixin`) | `controller.emailValidator` |
| Form key | `<screen>FormKey` | `loginFormKey` |
| TextEditingController | `<field>Controller` | `emailController` |
| Route name | camelCase const | `RouteNames.home`, `RouteNames.profile` |
| Constant | lowerCamelCase (Dart convention) | `AppConstants.defaultPageLimit` |
| i18n key | dot-namespaced | `auth.signIn`, `home.dashboard` |

---

## 6. Data flow (Login)

```
View
  │  AppButton(onPressed: controller.onLogin)
  ▼
LoginController.onLogin()                       ← extends BaseController
  │  runGuarded(() => _repo.login(LoginRequest(...)))
  ▼
AuthRepositoryImpl.login()                      ← try/catch
  │  await _ds.login(request)
  │  await _persist(response)                   ← SecureStorage + LocalStorage
  ▼
AuthRemoteDataSource.login()                    ← throws on !success
  │  await _api.post<LoginResponse>(ApiUrls.login, fromJson: ...)
  ▼
ApiClient                                       ← Dio + interceptors
  │  AuthInterceptor adds Bearer + CSRF
  │  TokenRefreshInterceptor handles 401
  ▼
Server
```

Controller never sees `ApiResponse`. View never sees the controller's `try/catch`. Errors surface as `state.value == ViewState.error` + `errorMessage.value`, which `StateSwitch` renders.

---

## 7. Code shape — Auth feature

See the actual files for reference — the auth feature is the canonical example.

- Interface: `lib/features/auth/domain/auth_repository.dart`
- Model: `lib/features/auth/data/user_model.dart` (no `toEntity()` — model IS the type)
- Datasource: `lib/features/auth/data/auth_remote_datasource.dart`
- Impl: `lib/features/auth/data/auth_repository_impl.dart`
- Controller: `lib/features/auth/presentation/login/login_controller.dart` (extends `BaseController`)
- Bindings: `lib/features/auth/presentation/login/login_bindings.dart`
- View: `lib/features/auth/presentation/login/login_view.dart` (`I18n.x.tr` everywhere)

---

## 8. BaseController

`lib/core/base/base_controller.dart`. Every feature controller extends this.

Provides:

- `state = ViewState.idle.obs`
- `errorMessage = ''.obs`
- `runGuarded<T>(body, {showErrorSnackbar, errorTag, emptyWhen})` — runs `body`, drives `state` transitions, catches, logs via `AppLogger.error` (which forwards to Crashlytics), optionally surfaces an error snackbar. Returns `T?` (null on failure).

When NOT to extend BaseController: orchestration-only controllers that compose other controllers without their own async state machine (e.g. `ProfileController`).

---

## 9. Errors

Layered — never collapse them.

- **Datasource** → throws on `!ApiResponse.success`.
- **Repo impl** → `try/catch` → rethrows as `Exception(e.toString())` after running side effects.
- **Controller** → `runGuarded` (or manual `try/catch`) → sets `state.value = ViewState.error`, `errorMessage.value = ...`, optional snackbar.
- **View** → branches via `StateSwitch` builders.

Uncaught errors (anywhere) → `AppErrorHandler` → `AppLogger.error` → `errorReportHook` → Crashlytics (when enabled).

`logout()` is the one allowed exception swallower — local cleanup must run even if the API call failed.

---

## 10. Dependency injection

See the DI table in [.claude/rules/architecture.md](../.claude/rules/architecture.md). Wired in `lib/core/di/initial_binding.dart`, called from `bootstrap()` before `runApp`.

---

## 11. Routing

- `core/routing/route_names.dart` — every named route.
- `core/routing/app_pages.dart` — every `GetPage` with binding + middleware.
- `core/routing/auth_middleware.dart` — reads `AuthController.isAuthenticated` synchronously.
- Analytics observer attached to `GetMaterialApp.navigatorObservers` auto-logs screen views.

Navigation: `Get.toNamed(RouteNames.x)` / `Get.offNamed` / `Get.offAllNamed`. Never `Navigator.of(context)`.

---

## 12. Network

- `ApiClient` — one long-lived `Dio` for the app's lifetime. Typed `get/post/put/patch/delete/uploadFile<T>` returning `ApiResponse<T>`. Reads `AppEnvironment.baseUrl` once at construction.
- `AuthInterceptor` — attaches `Bearer` token on every request; `x-csrf-token` on mutating methods. Reads from `SecureStorageService`.
- `TokenRefreshInterceptor` — single-flight 401 refresh. Queues concurrent 401s. **Never auto-logs-out**; `AuthController.logout()` is the only place that wipes session state.

---

## 13. UI state (ViewState + StateSwitch)

`enum ViewState { idle, loading, success, error, empty }`.

`StateSwitch` (in `shared/widgets/`) takes five builders: `onIdle`, `onLoading`, `onEmpty`, `onError`, `onSuccess`. Every list / detail screen uses this — never roll a per-screen state enum.

The sample `DashboardView` (`features/home/presentation/dashboard/dashboard_view.dart`) is the canonical reference.

---

## 14. i18n

- Translation files: `assets/i18n/<lang>.json` (currently `en.json`, `hi.json`).
- Keys: `lib/core/i18n/i18n_keys.dart` (typed constants — always use these).
- Usage: `Text(I18n.signIn.tr)` (`.tr` from GetX).
- Adding a key: edit each `<lang>.json` AND `i18n_keys.dart`. Run `make l10n` to see the pattern.
- Adding a language: drop a new JSON in `assets/i18n/`, extend `AppTranslations.supportedLocales`.
- Switching locale: `Get.find<LocaleController>().setLocale(const Locale('hi', 'IN'))` — persisted + reactive.

---

## 15. Theming

- Light + dark `ThemeData` built in `core/theme/app_theme.dart`. `_baseTheme` is brightness-aware via a `pick(light, dark)` helper.
- Tokens in `core/constants/app_colors.dart` — every themed surface has both a light and a dark token (`backgroundColor` + `backgroundDark`, `containerFillColor` + `containerFillDark`, etc.).
- Switching: `Get.find<ThemeController>().setMode(ThemeMode.dark)` — persisted via `Get.changeThemeMode`.
- Default: `ThemeMode.system` — first launch matches the device.

---

## 16. Telemetry (Crashlytics + Analytics)

- `core/services/crashlytics_service.dart` — gated by `ENABLE_CRASHLYTICS=true` in `.env`. Sets `AppLogger.errorReportHook = FirebaseCrashlytics.instance.recordError` so every `AppLogger.error` reaches the dashboard. Also receives `FlutterError`, `PlatformDispatcher`, and zone errors via `AppErrorHandler`.
- `core/services/analytics_service.dart` — gated by `ENABLE_ANALYTICS=true`. Exposes `observer` (NavigatorObserver) for screen views and `logEvent` / `setUserId` for explicit instrumentation.
- Both no-op safely when Firebase init failed (missing `google-services.json` / `GoogleService-Info.plist`).
- `AuthController` pushes user id to both services on login + clears on logout.

---

## 17. Notifications + deep links

Both services follow the same pattern: **whitelist input, expose a stream, never navigate**.

- `NotificationService(allowedTypes: { 'order', 'chat' })` — push payloads whose `type` is not in the set are dropped. Tap stream is `onTap: Stream<NotificationPayload>`.
- `DeepLinkService(allowedPaths: { '/order/', '/profile' })` — incoming URIs whose path doesn't match a prefix are dropped. Stream is `onLink: Stream<DeepLinkIntent>`.

A top-level coordinator (typically the splash controller, or an `AppLinkRouter`) subscribes to both streams and calls `Get.toNamed` after any further validation.

Platform configuration (Android intent filters, iOS Universal Links, FCM service files) is on the app developer — see the `app_links` and `firebase_messaging` READMEs.

---

## 18. Permissions

`core/services/permission_service.dart` wraps `permission_handler` with a typed `PermissionOutcome` enum (`granted`, `denied`, `permanentlyDenied`, `restricted`).

Request at the point of use, never on launch. On `permanentlyDenied`, show a confirmation and call `permissions.openSettings()` after the user gesture.

---

## 19. Connectivity

- `ConnectivityController` (permanent) subscribes to `connectivity_plus` and exposes `isOnline: RxBool`.
- `OfflineBanner` (in `shared/widgets/`) reacts to it — drop into any screen.
- For one-off checks use `ConnectivityService.isConnected` (static, returns `Future<bool>`).

---

## 19a. File downloads

`core/services/file_download_service.dart` — streams remote files via the existing Dio + interceptor stack.

```dart
final downloader = Get.find<FileDownloadService>();

final result = await downloader.download(
  url: '${AppEnvironment.baseUrl}/files/invoice_42.pdf',
  fileName: 'invoice_42.pdf',
  destination: DownloadDestination.downloads,   // or .appDocuments
  sendAuthHeader: true,                          // false for public CDN URLs
  onProgress: (received, total) {
    final pct = total > 0 ? received / total : 0.0;
    debugPrint('${(pct * 100).toStringAsFixed(0)}%');
  },
);

if (result.success) {
  AppSnackBar.success(message: 'Saved to ${result.path}');
} else {
  AppSnackBar.error(message: result.error ?? 'Download failed');
}
```

Safety baked in:

- URL scheme whitelist (`http` / `https` only).
- Filename sanitisation — server-supplied names are basename-only, with `..` collapsed.
- Resolved path verified to live inside the destination directory.
- `DioException` mapped to user-safe strings (timeout / no internet / `Server returned 404`).
- Partial files cleaned up on failure.

Platform notes:

- **Android**: `WRITE_EXTERNAL_STORAGE` is declared with `android:maxSdkVersion="28"`; modern Android uses scoped storage automatically. `DownloadDestination.downloads` falls back to app-private if storage permission is denied. Files in app-private storage are NOT visible in the system Files app on Android — use `downloads` if discoverability matters.
- **iOS**: there is no public Downloads folder. Both destinations resolve to the app sandbox `Documents/`. Files are visible in the iOS Files app because `UIFileSharingEnabled` + `LSSupportsOpeningDocumentsInPlace` are set in `Info.plist`.

To open the file after download (e.g. preview a PDF), add `open_filex` to `pubspec.yaml` and call `OpenFilex.open(result.path!)`. Intentionally not bundled to keep the dependency surface small.

## 20. Logging

`core/utils/app_logger.dart`. Levels: `debug`, `info`, `success`, `warning`, `error`, `data`. Gated by `kDebugMode || enableLogging`. Always pass `tag:` (and `error:` + `stackTrace:` for errors). Crashlytics gets every `error()` call via `errorReportHook`.

---

## 21. Adding a new feature

Example: `products`.

```
lib/features/products/
├── domain/
│   └── products_repository.dart                # abstract ProductsRepository
├── data/
│   ├── product_model.dart                      # fromJson/toJson/copyWith
│   ├── products_remote_datasource.dart
│   └── products_repository_impl.dart
└── presentation/
    └── product_list/
        ├── product_list_view.dart              # GetView<ProductListController>, uses StateSwitch
        ├── product_list_controller.dart        # extends BaseController
        └── product_list_bindings.dart          # Get.lazyPut DS → Repo → Controller
```

1. Define the interface in `domain/`.
2. Add `EP_PRODUCTS_LIST` (etc.) to `.env` + `.env.example` + `ApiUrls`.
3. Implement datasource + repo impl, throw → rethrow as `Exception`.
4. Controller extends `BaseController`. Use `runGuarded` for every async action.
5. View uses `StateSwitch` for loading/empty/error/success branches.
6. Add new strings to `assets/i18n/en.json` + `hi.json` + `I18n` keys.
7. Add `RouteNames.productList` + a `GetPage` in `AppPages` (`middlewares: [AuthMiddleware()]` if protected).
8. Tests: controller + repo impl (mock the domain interface for controller; mock datasource + storage for repo impl).

---

## 22. Adding a new screen to an existing feature

1. Create `features/<feature>/presentation/<screen>/` with 3 files.
2. Add a method to the existing `<Feature>Repository` interface if a new endpoint is needed; implement in the impl + datasource.
3. Add `RouteNames.<screen>` + a `GetPage` in `AppPages`.
4. Add the screen's strings to `i18n_keys.dart` + every `<lang>.json`.

---

## 23. Starting a new project from this skeleton

1. **Rename the package.** Change `name: app_structure` in `pubspec.yaml`, the Android package id (`com.example.app_structure`), the iOS bundle id, and search-replace `package:app_structure/` across the codebase.
2. **Drop placeholder content.** Replace the sample home feature (`features/home/`) with your real feature. Update `RouteNames.home` if you want a different default landing route.
3. **Wire `.env`.** Copy `.env.example` to `.env` (`make env-setup`), fill in `BASE_URL_*` + `EP_*` keys. Add `ENABLE_LOGGING`, `ENABLE_CRASHLYTICS`, `ENABLE_ANALYTICS` as needed.
4. **Firebase.** Run `flutterfire configure` (or drop in `google-services.json` + `GoogleService-Info.plist` manually). Without these, telemetry no-ops cleanly — but FCM + push won't work.
5. **Permissions config.** Add the relevant entries to `AndroidManifest.xml` and `Info.plist` for each permission you actually use.
6. **App icons + splash.** Add `flutter_launcher_icons` / `flutter_native_splash` to `dev_dependencies`, configure in `pubspec.yaml`, run `make icons` / `make splash`.
7. **Translations.** Either keep English only (delete `hi.json` + drop Hindi from `supportedLocales`) or add your real target languages.
8. **Theme.** Update `AppColors.primaryColor` and the dark variants. Customise `AppTheme._baseTheme` if needed.
