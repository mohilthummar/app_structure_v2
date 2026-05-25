# app_structure

A production-leaning Flutter skeleton with clean architecture (GetX), Dio + interceptors, env-based config, i18n (English + Hindi), light/dark/system theming, Firebase Crashlytics + Analytics (guarded), notifications + deep links with safety whitelists, connectivity tracking, and a sample home (dashboard + profile) feature you can clone for new screens.

Authoritative architecture doc: [docs/PROJECT_ARCHITECTURE.md](docs/PROJECT_ARCHITECTURE.md)

---

## Quick start

```bash
# 1. Copy .env from template + edit values
make env-setup

# 2. Install deps
flutter pub get

# 3. Run (defaults to EnvironmentType.development — change in lib/main.dart)
make run
```

`.env` is gitignored. Keep `.env.example` in sync whenever you add a new key.

---

## What's in the box

| Layer | Where |
|---|---|
| Entry + boot orchestration | `lib/main.dart`, `lib/bootstrap.dart` |
| Error handling | `lib/core/error/app_error_handler.dart` (FlutterError + PlatformDispatcher + Zone) |
| Logging | `lib/core/utils/app_logger.dart` (gated by `enableLogging`, forwards errors to Crashlytics) |
| Config | `lib/core/config/{app_environment,api_urls}.dart` |
| DI | `lib/core/di/initial_binding.dart` (one place wires everything) |
| Storage | `lib/core/storage/{secure_storage,local_storage}.dart` |
| Network | `lib/core/network/{api_client,auth_interceptor,token_refresh_interceptor,api_response}.dart` |
| Routing | `lib/core/routing/{route_names,app_pages,auth_middleware}.dart` |
| UI state | `lib/core/enums/view_state.dart` + `lib/shared/widgets/state_switch.dart` |
| Theme | `lib/core/theme/*` (brightness-aware) + `lib/core/controllers/theme_controller.dart` |
| i18n | `lib/core/i18n/*` + `assets/i18n/*.json` + `lib/core/controllers/locale_controller.dart` |
| Telemetry | `lib/core/services/{crashlytics_service,analytics_service}.dart` (gated by .env flags) |
| Notifications | `lib/core/services/notification_services.dart` (whitelist-validated, stream-based) |
| Deep links | `lib/core/services/deep_linking_manager.dart` (whitelist-validated, stream-based) |
| Permissions | `lib/core/services/permission_service.dart` (typed outcomes) |
| Connectivity | `lib/core/controllers/connectivity_controller.dart` + `lib/shared/widgets/offline_banner.dart` |
| App info | `lib/core/services/app_info_service.dart` (package_info_plus) |
| File downloads | `lib/core/services/file_download_service.dart` (Dio streaming, sanitized paths, cancel token, progress) |
| Base controller | `lib/core/base/base_controller.dart` (state + errorMessage + runGuarded) |
| Auth feature | `lib/features/auth/` (splash, login, forgot-password) |
| Sample feature | `lib/features/home/` (dashboard with pagination, profile with theme + language pickers + logout) |

---

## Commands

`make help` lists everything. Highlights:

| Goal | Command |
|---|---|
| Run app | `make run` (debug) / `make run-release` |
| Verify everything | `make verify` (pub get + fix + format-check + analyze + test) |
| Single test | `make test-file FILE=test/...` |
| Setup `.env` | `make env-setup` |
| Native splash | `make splash` (after adding `flutter_native_splash` config) |
| App icons | `make icons` (after adding `flutter_launcher_icons` config) |
| List translations | `make l10n` |
| Deep clean | `make hard-clean` |

---

## Environment + .env

Single `.env` file; which keys are read is picked by `EnvironmentType` in `lib/main.dart` (no flavors, no `--dart-define`):

```dart
await bootstrap(environment: EnvironmentType.development);
// or .local, .staging, .production
```

`AppEnvironment.baseUrl` resolves to one of `BASE_URL_LOCAL` / `BASE_URL_DEV` / `BASE_URL_STAGING` / `BASE_URL_PROD`. Endpoint paths live in `EP_*` keys.

**Feature flags read from `.env`:**
- `ENABLE_LOGGING` (also gates `pretty_dio_logger`)
- `ENABLE_CRASHLYTICS`
- `ENABLE_ANALYTICS`

Reading `AppEnvironment` or `ApiUrls` before `bootstrap()` awaits throws `dotenv unloaded` — bootstrap order matters.

---

## Firebase

The skeleton ships with `firebase_core`, `firebase_messaging`, `firebase_crashlytics`, `firebase_analytics`. Firebase init in `bootstrap.dart` is **guarded** — missing `google-services.json` / `GoogleService-Info.plist` logs and continues; Crashlytics + Analytics services no-op cleanly. The app boots either way.

To wire it up properly:

```bash
# Recommended — runs once, configures Android + iOS + web
flutterfire configure
```

Or drop in the platform files manually:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

Set `ENABLE_CRASHLYTICS=true` and `ENABLE_ANALYTICS=true` in `.env` to turn on collection.

---

## Boot order (don't reorder)

`main.dart` is 5 lines: `runZonedGuarded(() async { await bootstrap(environment: ...); runApp(...); }, AppErrorHandler.onZoneError);`

Every step lives in `bootstrap.dart`:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `AppErrorHandler.init()`
3. `dotenv.load()`
4. `AppEnvironment.setEnvironment(env)`
5. Firebase init (guarded)
6. System chrome + portrait lock
7. `InitialBinding().dependencies()`
8. `LocalStorageService.init()`
9. Crashlytics + Analytics init
10. Load `AppTranslations` + `LocaleController` + `ThemeController`

Then `runApp`.

---

## Architecture in 30 seconds

```
Presentation ──> Domain (interface only) <── Data (impl)
   View                                       │
   Controller (extends BaseController)        ├── *Model (fromJson/toJson) — THE type
   Bindings (DI wiring)                       ├── *RemoteDataSource (calls ApiClient)
                                              └── *RepositoryImpl (try/catch, persists side effects)
```

- Controllers depend on the **interface** in `domain/`, never on the impl.
- `*Model` flows through every layer — no entity / DTO split, no `toEntity()`.
- Errors travel as `Exception` until they hit the controller, which sets `state = ViewState.error` + `errorMessage`.
- Views render via `StateSwitch` — loading / empty / error / success builders.
- Strings via `I18n.<key>.tr`, colors via `AppColors.x`, sizes via `AppDimensions.x` — never inline.

Full contract: [docs/PROJECT_ARCHITECTURE.md](docs/PROJECT_ARCHITECTURE.md). One-page version: [.claude/rules/architecture.md](.claude/rules/architecture.md).

---

## Starting a new project from this skeleton

See section 23 of [docs/PROJECT_ARCHITECTURE.md](docs/PROJECT_ARCHITECTURE.md#23-starting-a-new-project-from-this-skeleton) for the full checklist. TL;DR:

1. Rename the package (`app_structure` → your name).
2. Replace `features/home/` with your real feature.
3. Fill in `.env` (`BASE_URL_*`, `EP_*`, feature flags).
4. Add Firebase config files (or run `flutterfire configure`).
5. Add iOS / Android permission entries for what you actually use.
6. Update `AppColors.primaryColor` + dark variants to your brand.
7. Ship the languages you actually need (delete `hi.json` if you don't want Hindi).
