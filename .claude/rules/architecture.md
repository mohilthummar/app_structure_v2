---
alwaysApply: true
---

# Architecture

Single-page summary of the skeleton's shape. The longer narrative lives in [docs/PROJECT_ARCHITECTURE.md](../../docs/PROJECT_ARCHITECTURE.md).

## Boot flow (don't reorder)

`main.dart` only wraps `runApp` in `runZonedGuarded` and calls `bootstrap(environment: ...)`. The single source of truth for boot order is `bootstrap.dart`:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `AppErrorHandler.init()` — installs `FlutterError.onError` + `PlatformDispatcher.instance.onError`
3. `await dotenv.load(fileName: '.env')`
4. `AppEnvironment.setEnvironment(env)` — selects which `BASE_URL_*` / `EP_*` keys are returned
5. Firebase init (guarded — missing `google-services.json` / `GoogleService-Info.plist` logs + continues; never crashes boot)
6. System chrome + portrait lock
7. `InitialBinding().dependencies()` — wires DI graph (ApiClient reads `AppEnvironment.baseUrl` at this point)
8. `await Get.find<LocalStorageService>().init()` — GetStorage warmup so all subsequent reads are sync
9. `CrashlyticsService.init()` + `AnalyticsService.init()` — wires `AppLogger.errorReportHook`; no-ops if Firebase failed
10. Load `AppTranslations` + register `LocaleController` + register `ThemeController`
11. `runApp(const MyApp())`

`runZonedGuarded` wraps steps 1–11 and forwards uncaught errors to `AppErrorHandler.onZoneError`.

## Layer contract (per feature)

```
features/<name>/
  domain/<name>_repository.dart            # abstract interface ONLY
  data/<name>_remote_datasource.dart       # calls ApiClient → *Model; throws Exception on !success
  data/<name>_repository_impl.dart         # try/catch + rethrow; persists via SecureStorage/LocalStorage
  data/<name>_model.dart                   # fromJson + toJson + copyWith — used by ALL layers
  presentation/<screen>/
    <screen>_bindings.dart                 # Get.lazyPut DS → Repo → Controller (repo as INTERFACE)
    <screen>_controller.dart               # extends BaseController; on* methods returning Future<bool> or Future<void>
    <screen>_view.dart                     # GetView<XController>; renders via StateSwitch
```

**Rule:** controllers depend on the `domain/` interface only. `*Model` flows through all layers (no entity/DTO split). `ApiResponse<T>` stays inside the data layer.

## BaseController (every feature controller extends this)

`lib/core/base/base_controller.dart` bundles:

- `state = ViewState.idle.obs`
- `errorMessage = ''.obs`
- `runGuarded<T>(body, {showErrorSnackbar, errorTag, emptyWhen})` — async wrapper that drives state transitions, catches, logs via `AppLogger.error` (→ Crashlytics), optionally snackbars. Cuts ~10 LOC per `on*` action.

Reach for plain `GetxController` only when the controller has no async state machine (e.g. `ProfileController` which composes other controllers).

## DI

All wiring lives in `lib/core/di/initial_binding.dart`, called from `bootstrap()` before `runApp`.

| Lifecycle | Why | Services |
|---|---|---|
| `Get.put(..., permanent: true)` | Must outlive `Get.deleteAll` (logout teardown). Holds session-spanning state. | `SecureStorageService`, `LocalStorageService`, `CrashlyticsService`, `AnalyticsService`, `ConnectivityController`, `DeepLinkService`, `NotificationService`, `AuthController`, `AppTranslations`, `LocaleController`, `ThemeController` |
| `Get.lazyPut(..., fenix: true)` | Re-created after logout teardown; cheap to build; not session-spanning. | `AppInfoService`, `PermissionService`, `DeviceInfoService`, `ApiClient`, `FileDownloadService`, `AuthRemoteDataSource`, `AuthRepositoryImpl` |
| Screen `Bindings` (`Get.lazyPut`) | Disposed when the route is popped. | Per-screen `DataSource → Repository (as interface) → Controller` |

**Always** register repos as the interface: `Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(...))`.

## Routing

- `core/routing/route_names.dart` — `abstract class RouteNames` constants.
- `core/routing/app_pages.dart` — `AppPages.pages: List<GetPage>`.
- `core/routing/auth_middleware.dart` — `GetMiddleware` reading `AuthController.isAuthenticated`. Protected routes list `middlewares: [AuthMiddleware()]`.
- Public: `splash`, `login`, `forgotPassword`. Protected: `home` (`DashboardView`), `profile` (`ProfileView`).
- Screen-view tracking: `Get.find<AnalyticsService>().observer` is registered in `GetMaterialApp.navigatorObservers`.

## Network

- `core/network/api_client.dart` — one long-lived `Dio` per app lifetime. Typed `get/post/put/patch/delete/uploadFile` returning `ApiResponse<T>`.
- `core/network/auth_interceptor.dart` — Bearer on every request, CSRF on mutating methods. Reads from `SecureStorageService`.
- `core/network/token_refresh_interceptor.dart` — single-flight 401 refresh with queued retries. **Never auto-logout**; callers decide via `AuthController.logout()`.

## UI state

- `core/enums/view_state.dart` — `enum ViewState { idle, loading, success, error, empty }`.
- `shared/widgets/state_switch.dart` — branches on `ViewState` to render loading/empty/error/success builders. Every screen uses this.
- `shared/widgets/offline_banner.dart` — drop-in widget that reacts to `ConnectivityController.isOnline`.

## i18n (every visible string)

- `core/i18n/app_translations.dart` — extends GetX `Translations`, loads `assets/i18n/<lang>.json` at boot.
- `core/i18n/i18n_keys.dart` — typed constants (`I18n.signIn`, `I18n.verify`, …). Always use these, never raw `'auth.signIn'.tr`.
- `core/controllers/locale_controller.dart` — permanent, persisted, exposes `setLocale(Locale)`.
- Adding a key: edit each `assets/i18n/<lang>.json` AND add the typed constant to `i18n_keys.dart`. Adding a language: drop a new JSON + extend `AppTranslations.supportedLocales`.

## Theme

- `core/controllers/theme_controller.dart` — permanent, persisted, `setMode(ThemeMode)` propagates via `Get.changeThemeMode`.
- `core/theme/app_theme.dart` — `_baseTheme` is brightness-aware (uses `pick(light, dark)` helper). Add a new themed surface → add both light + dark tokens to `AppColors` AND pick them in `_baseTheme`.

## Telemetry

- `core/services/crashlytics_service.dart` — gated by `enableCrashlytics`. `init()` sets `AppLogger.errorReportHook` so every `AppLogger.error(...)` reaches Crashlytics. Also called from `AppErrorHandler` hooks.
- `core/services/analytics_service.dart` — gated by `enableAnalytics`. Exposes `observer` for screen-view auto-logging + `logEvent` / `setUserId` for explicit instrumentation.
- Both no-op when Firebase init failed (`Firebase.apps.isEmpty`) — safe to call from anywhere without a guard.

## Notifications + deep links

- `core/services/notification_services.dart` — injectable, no globals. Exposes `onTap: Stream<NotificationPayload>` — consumers subscribe and decide where to navigate. Payload `type` field is **whitelisted** via the `allowedTypes` constructor arg; non-whitelisted payloads are dropped.
- `core/services/deep_linking_manager.dart` — `DeepLinkService` using `app_links`. Exposes `onLink: Stream<DeepLinkIntent>`. Paths are validated against `allowedPaths` prefix set; empty set = safe default.
- Neither service navigates — a top-level coordinator (e.g. splash controller, or a dedicated `AppLinkRouter`) listens to the stream and calls `Get.toNamed`.

## File downloads

- `core/services/file_download_service.dart` — wraps `ApiClient.dio.download` with safe path resolution, filename sanitisation (path-traversal proof), URL scheme whitelist (`http`/`https` only), Android permission handling, and `DioException` → user-safe error mapping.
- Two destinations: `DownloadDestination.appDocuments` (no permission, works on both platforms — visible in iOS Files app via `UIFileSharingEnabled`) and `DownloadDestination.downloads` (Android public Downloads folder; iOS falls back to appDocuments).
- For unauthenticated CDN URLs pass `sendAuthHeader: false` — the request goes through with `extra: {AuthInterceptor.skipAuthKey: true}` so the Bearer token is suppressed.
- Cancellation: pass a `CancelToken` and call `cancelToken.cancel()` to abort mid-stream. Progress: pass `onProgress: (received, total) => ...`.
- Android manifest already declares `INTERNET`, `WRITE_EXTERNAL_STORAGE` (≤ API 28), `READ_EXTERNAL_STORAGE` (≤ API 32), `POST_NOTIFICATIONS`. iOS `Info.plist` declares the usual permission usage strings + `UIFileSharingEnabled` for Files-app integration.

## Logging

- `core/utils/app_logger.dart` — `debug/info/success/warning/error/data`, gated by `kDebugMode || enableLogging`. `error(...)` forwards to `errorReportHook` (Crashlytics) regardless of the print gate.
- Never use `print()` (caught by `avoid_print` lint). Use `AppLogger.*` or `debugPrint` for very low-level cases.
