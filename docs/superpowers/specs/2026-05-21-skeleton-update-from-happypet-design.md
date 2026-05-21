# Skeleton update — `app_structure_v2` ← reusable infra from `happypet-flutter-development`

**Status:** Draft for user review
**Date:** 2026-05-21
**Owner:** Mohil Thummar
**Scope:** Refactor `app_structure_v2` into a clean, reusable Flutter project skeleton by mining `happypet-flutter-development` for proven infrastructure, utilities, and patterns. Do NOT port business features (bookings, clinic, inventory, etc.).

---

## 1. Goals

The skeleton must serve six explicit goals, in priority order:

1. **Fast cold start** — minimal eager work in `bootstrap()`.
2. **Less code per feature** — boilerplate is the enemy; reuse > re-implement.
3. **Reusable across projects** — every file in the skeleton is generic. Zero business names.
4. **Easy API calls** — typed one-liners at the datasource boundary.
5. **Predictable UI states** — every screen uses the same loading/empty/error/success shape.
6. **Performance** — long-lived clients, lazy DI, no per-call object recreation.

These goals trace through every design decision below.

## 2. Source-of-truth decisions (locked in via brainstorming)

| # | Decision | Choice |
|---|---|---|
| 1 | Layer purity | **Keep strict** — controllers/views never import from `data/`. |
| 2 | Feature folder layout | **Keep v2 flat** — `data/*.dart`, `domain/*.dart`, `presentation/<screen>/*.dart` (no nested `datasources/models/repositories/`, no barrel files). |
| 3 | Network pattern | **Adopt happypet's `ApiClient` + `ApiResponse<T>`** — replaces v2's `ClientService` + `BaseResponse` + `Result`. |
| 4 | Auth example screens | **Splash + Login + Forgot Password** (drop sign_up, skip 2FA). |
| 5 | DI wiring | **Dedicated `core/di/initial_binding.dart`** — replaces `LazyBinding` inside `app.dart`. |
| 6 | What to pull from happypet | Core utils + models (no snack), AppDimensions + AppTypography tokens, generic UI widgets, SecureStorage + Firebase plumbing. **Keep v2's `AppSnackBar`** — refactor only. |
| 7 | Sizing + fonts | **Keep ScreenUtil**, keep `AppText` widget (rewire internals to AppTypography tokens), keep bundled OpenSans (no GoogleFonts runtime). |
| 8 | Local storage backend | **Keep GetStorage** (sync after init). Rename `Preferences` → `LocalStorageService` with happypet-style named accessors. |
| 9 | Entity layer | **Drop the entity layer.** `*Model` IS the type across all layers. `domain/` only holds the abstract Repository interface. (Resolves Goal 2 conflict with Decision 1.) |
| 10 | Firebase init | **Eager init always** (user explicitly accepted the ~200–400 ms cold-start cost). |
| 11 | UI state contract | **Add `ViewState` enum** — `idle/loading/success/error/empty` + shared `StateSwitch` widget. (Resolves Goal 5.) |

## 3. Architecture

### 3.1 Layer contract

```
features/<name>/
  domain/
    <name>_repository.dart            // abstract interface ONLY
  data/
    <name>_remote_datasource.dart     // calls ApiClient, returns *Model, throws Exception on failure
    <name>_repository_impl.dart       // implements interface, persists/clears state
    <name>_model.dart                 // fromJson + copyWith. Used by ALL layers (no toEntity()).
  presentation/<screen>/
    <screen>_bindings.dart            // lazyPut DataSource → Repository → Controller
    <screen>_controller.dart          // state, errorMessage, typed data + on* actions
    <screen>_view.dart                // GetView<XController>
```

### 3.2 Per-screen state contract

Every controller exposes the same Rx shape:

```dart
final state         = ViewState.idle.obs;   // idle | loading | success | error | empty
final errorMessage  = ''.obs;
// + typed data fields (e.g. final users = <UserModel>[].obs;)
```

`ViewState` lives in `lib/core/enums/view_state.dart`. Views branch via a shared `StateSwitch` widget (in `lib/shared/widgets/state_switch.dart`) that maps each state → loading skeleton / empty / error / content.

### 3.3 Layer responsibilities

| Layer | Returns | On error |
|---|---|---|
| DataSource | `*Model` (or `List<*Model>` / `void`) | `throw Exception(response.error?.message ?? '...')` |
| Repository impl | same `*Model` | try/catch → rethrow `Exception(e.toString())`; persist side-effects (tokens, profile) |
| Controller | `Future<bool>` for `on*` actions | try/catch → set `state.value = error`, `errorMessage.value = ...`, optionally `AppSnackBar.error` |
| View | Widget | Branches on `state.value` via `StateSwitch`. No try/catch. |

### 3.4 Boundaries

- Controllers depend on `XRepository` (the abstract interface) — never on `XRepositoryImpl` or `XRemoteDataSource`.
- `*Model` flows freely through all layers (no `toEntity()` mapping).
- `ApiResponse<T>` stays inside the data layer — never reaches controllers.
- `BuildContext` never crosses an `await` in a controller. Controllers return `Future<bool>`; views gate UI on `if (context.mounted && ok) ...`.

### 3.5 Boot flow

```
main()
 ├─ WidgetsFlutterBinding.ensureInitialized()
 ├─ await bootstrap()                       // dotenv.load(), Firebase.initializeApp(),
 │                                          // SystemUiOverlayStyle, orientation lock
 ├─ AppEnvironment.setEnvironment(...)      // reads BASE_URL_* from .env
 ├─ InitialBinding().dependencies()         // registers permanent + lazy services
 ├─ await Get.find<LocalStorageService>().init()   // GetStorage warmup
 └─ runApp(const MyApp())
       └─ ScreenUtilInit → GetMaterialApp
              initialRoute = RouteNames.splash
              getPages     = AppPages.pages
```

`InitialBinding.dependencies()` registration order:

```
SecureStorageService              (Get.put, permanent)
LocalStorageService               (Get.put, permanent)
DeviceInfoService                 (Get.lazyPut, fenix)         // needs LocalStorage
ApiClient                         (Get.lazyPut, fenix)         // needs SecureStorage
AuthRemoteDataSource              (Get.lazyPut, fenix)         // needs ApiClient
AuthRepository                    (Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(...)), fenix)
AuthController                    (Get.put, permanent)         // needs AuthRepository
```

### 3.6 Request flow

```
Controller.onSomething()
 └─ try { data = await _repo.method(); state.value = success; }
       │
       ▼
  Repository.method()
   └─ try { return await _ds.method(); } catch (e) { rethrow Exception(e.toString()); }
       │
       ▼
  DataSource.method()
   └─ final res = await _api.get<XModel>(ApiUrls.endpoint, fromJson: XModel.fromJson);
      if (!res.success) throw Exception(res.error?.message ?? 'Failed');
      return res.data!;
       │
       ▼
  ApiClient.get(...)
   └─ Dio.get(versionedPath)
        ├─ AuthInterceptor.onRequest      → adds Bearer + CSRF (POST/PUT/PATCH/DELETE only)
        ├─ TokenRefreshInterceptor.onError → on 401: single-flight refresh, queued retries
        └─ PrettyDioLogger (kDebugMode && enableLogging)
      → returns ApiResponse<T>.fromSuccess(parsed) | fromError(ApiErrorModel.fromDioException(e))
```

### 3.7 Logout teardown

`AuthController.logout()` is the single entrypoint. Any logout button calls it; no other path clears tokens or navigates after auth failure.

```
AuthController.logout()
 ├─ try { await _repo.logout(deviceId: localStorage.deviceId); } catch { /* tolerate API failure */ }
 ├─ user.value = null
 ├─ await secureStorage.clearAll()        // tokens, csrf, refresh
 ├─ await localStorage.clearUserData()
 ├─ Get.offAllNamed(RouteNames.login)
 └─ await Future<void>.delayed(Duration.zero); await Get.deleteAll(force: false)
                                          // wipes lazy controllers/repos/datasources;
                                          // permanents (storage, ApiClient, AuthController) survive
```

## 4. File inventory

### 4.1 Files to ADD (~25)

**`lib/core/di/`** (1)
- `initial_binding.dart`

**`lib/core/network/`** (4) — replaces v2's `client_service`/`base_response`/`header_builder`/`interceptor`
- `api_client.dart`
- `api_response.dart`
- `auth_interceptor.dart`
- `token_refresh_interceptor.dart`

**`lib/core/storage/`** (1)
- `secure_storage.dart`

**`lib/core/controllers/`** (1)
- `auth_controller.dart`

**`lib/core/routing/`** (1) — replaces `lib/routes/` folder
- `auth_middleware.dart`

**`lib/core/theme/`** (2)
- `app_dimensions.dart`
- `app_typography.dart`

**`lib/core/utils/`** (4)
- `validators.dart`
- `string_utils.dart`
- `date_utils.dart`
- `file_utils.dart`

**`lib/core/enums/`** (2)
- `environment_enums.dart`
- `view_state.dart`

**`lib/core/services/`** (1)
- `device_info_service.dart`

**`lib/shared/models/`** (2)
- `api_error_model.dart`
- `pagination_model.dart`

**`lib/shared/widgets/`** (~10)
- `state_switch.dart` (the `ViewState` view-side glue)
- `app_modal.dart`
- `app_loading.dart`
- `app_empty_state.dart`
- `app_skeleton.dart`
- `app_checkbox.dart`
- `app_switch.dart`
- `app_radio_button.dart`
- `app_chip.dart`
- `app_tab_bar.dart`

**`lib/features/auth/`** (~8 new files)
- `data/login_request.dart`
- `data/login_response.dart`
- `presentation/login/{login_bindings, login_controller, login_view}.dart`
- `presentation/forgot_password/{forgot_password_bindings, forgot_password_controller, forgot_password_view}.dart`

### 4.2 Files to MODIFY / REWRITE (~17)

| File | Change |
|---|---|
| `lib/main.dart` | Add Firebase init, `Get.put(SecureStorage/LocalStorage)`, `InitialBinding().dependencies()`, `LocalStorageService.init()`. |
| `lib/bootstrap.dart` | Add `Firebase.initializeApp()`, status bar style. |
| `lib/app.dart` | Drop `LazyBinding` class. Switch `pages` → `AppPages.pages`. Switch `RoutesName.splashView` → `RouteNames.splash`. |
| `lib/core/config/api_url.dart` | Rename → `api_urls.dart`. Add `apiV1`/`apiV2` constants and auth endpoints (`login`, `logout`, `refreshToken`, `forgotPassword`, `verifyToken`). |
| `lib/core/config/app_environment.dart` | Add `webOrigin` getter (for refresh-token `Origin` header). |
| `lib/core/constants/constants.dart` | Rename → `app_constants.dart`. Add `tokenKey`, `refreshTokenKey`, `csrfTokenKey`, `csrfHeaderName`, `connectTimeout`, `receiveTimeout`, `searchDebounce`, `defaultPageLimit`. |
| `lib/core/constants/app_colors.dart` | Expand with happypet's color scale (orange25–900, gray25–900, status/toast colors). Preserve existing tokens that current views use. |
| `lib/core/enums/common_enums.dart` | Add `ButtonVariant`, `ToastType`, `ModalVariant`, `InputSize`, `CheckboxSize`. |
| `lib/core/enums/enums.dart` | Barrel: export api/environment/view_state/common. |
| `lib/core/mixins/validation_mixin.dart` | Back the mixin with the new `Validators` static class (preserves existing mixin call sites). |
| `lib/core/storage/preferences.dart` | Rename → `local_storage.dart`. Class `Preferences` → `LocalStorageService`. Keep GetStorage backend. Adopt happypet-style named accessors (`userDataJson`, `deviceId`, etc.). Fix the broken `user` setter (`jsonDecode(u.toString())` bug). |
| `lib/core/theme/app_theme.dart` | Use `AppDimensions` + `AppTypography` tokens (no inline numbers or styles). |
| `lib/core/theme/app_text.dart` | Rewire `TextSize` enum branches to return `AppTypography` tokens. Keep the widget API stable for existing call sites. |
| `lib/shared/widgets/app_button.dart` | Refactor to use `ButtonVariant` enum + `AppDimensions` + `AppTypography`. |
| `lib/shared/widgets/app_text_field.dart` | Refactor to use `AppDimensions.inputPadding/inputHeight` + tokens. |
| `lib/shared/widgets/app_drop_down.dart` | Refactor with happypet-style API (`items`, `value`, `onChanged`, error state). |
| `lib/features/auth/presentation/splash/splash_controller.dart` | Rewrite for new `AuthController.checkAuth()` flow. |
| `lib/core/utils/app_snack_bar.dart` | Refactor to use `AppColors`/`AppTypography` tokens (no inline `Color(0xFF…)` or sizes). Keep public API. |

### 4.3 Files to DROP

| File | Reason |
|---|---|
| `lib/core/base/base_view_controller.dart` | Unused / empty scaffold. |
| `lib/core/base/overlay_controller.dart` | Debug-only artifact, not skeleton-worthy. |
| `lib/core/network/base_response.dart` | Replaced by `ApiResponse<T>`. |
| `lib/core/network/client_service.dart` | Replaced by `ApiClient`. |
| `lib/core/network/header_builder.dart` | Interceptors handle all headers. |
| `lib/core/network/interceptor.dart` | Replaced by `auth_interceptor` + `token_refresh_interceptor`. |
| `lib/core/types/result.dart` | Exception-based flow replaces it. |
| `lib/features/auth/domain/user.dart` | Entity layer dropped. |
| `lib/features/auth/presentation/sign_in/` (3 files) | Renamed to `login/`, rewritten. |
| `lib/features/auth/presentation/sign_up/` (3 files) | Replaced by `forgot_password/`. |
| `lib/shared/widgets/app_animated_cliprect.dart` | Duplicate of `lib/shared/packages/app_animated_cliprect.dart`. |
| `lib/routes/routes.dart`, `lib/routes/routes_name.dart` | Moved to `lib/core/routing/app_pages.dart` + `route_names.dart`. |

### 4.4 Files KEPT AS-IS (or near-as-is)

Not enumerated individually; covers:

- `lib/core/extensions/*` (3): `currency_extension`, `date_extension`, `number_extension`
- `lib/core/mixins/mixins.dart`
- `lib/core/services/*` (3): `connectivity_service`, `deep_linking_manager`, `notification_services`
- `lib/core/constants/{app_strings, app_assets}.dart`
- `lib/core/utils/*`: `app_loader`, `color_print`, `image_sheet`, `shimmer_utils`, `stretch_scroll_behavior`, `ui_utils`, `utils`
- `lib/core/utils/formatters/*` (3)
- `lib/shared/models/drop_down_model.dart`
- `lib/shared/packages/*` (~11)
- `lib/shared/widgets/*` kept: `app_app_bar`, `app_icon_button`, `app_image_view`, `app_pin_code_field`, `bottom_border_container`, `country_code_picker/`, `screen_header`
- `lib/features/auth/presentation/shared/otp_dialog.dart`
- `lib/features/auth/presentation/splash/{splash_view, splash_bindings}.dart` (controller is rewritten)

### 4.5 `pubspec.yaml` changes

**Add:**
- `flutter_secure_storage: ^9.x`

**No removals.** All current deps stay.

**Net file change:** +~25 added, ~13 dropped (plus renames), ~17 modified. Net `lib/` grows by ~12 files.

## 5. New `core/` modules — interface summaries

### 5.1 `core/network/api_client.dart`

```dart
class ApiClient {
  ApiClient(SecureStorageService secureStorage);

  Dio get dio;

  Future<ApiResponse<T>> get<T>(String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
    String? version,
  });

  // post / put / patch / delete: same shape
  // uploadFile: multipart, supports POST/PUT/PATCH
}
```

- Long-lived single `Dio`. `BaseOptions` set once (baseUrl, timeouts, content type).
- Interceptors attached once: `AuthInterceptor`, `TokenRefreshInterceptor`, optional `PrettyDioLogger` (gated on `kDebugMode && AppEnvironment.enableLogging`).
- `versionedPath`: prepends `/v1` (or `version` argument) to the path.
- Internal `_request<T>(...)` wraps the Dio call in try/catch and returns `ApiResponse<T>.fromSuccess` or `ApiResponse<T>.fromError(ApiErrorModel.fromDioException(e))`.

### 5.2 `core/network/api_response.dart`

```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiErrorModel? error;

  factory ApiResponse.fromSuccess(T data, {String? message});
  factory ApiResponse.fromError(ApiErrorModel error);
}
```

### 5.3 `core/network/auth_interceptor.dart`

- `onRequest`: read `SecureStorageService.getToken()` → set `Authorization: Bearer <token>`. For `POST/PUT/PATCH/DELETE`, also attach CSRF header (`AppConstants.csrfHeaderName`) from `SecureStorageService.getCsrfToken()`.

### 5.4 `core/network/token_refresh_interceptor.dart`

- `onError`: only handles 401. Other status codes pass through.
- Skip the refresh endpoint itself (no loops).
- Single-flight: `_isRefreshing` boolean + `_failedQueue: List<_PendingRequest>`. Concurrent 401s queue and resume on the same refresh result.
- Refresh call uses a **clean Dio** with no `AuthInterceptor` (so the expired access token can't overwrite the Authorization header). Includes refresh token in body **and** Cookie header, plus `Origin`/`Referer` from `AppEnvironment.webOrigin`.
- **Never auto-logout.** Refresh failure propagates the original 401 — callers decide (typically `AuthController.logout()`).

### 5.5 `core/storage/secure_storage.dart`

```dart
class SecureStorageService {
  SecureStorageService();    // FlutterSecureStorage with encryptedSharedPreferences on Android

  Future<void>    saveToken(String token);
  Future<String?> getToken();
  Future<void>    saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void>    saveCsrfToken(String token);
  Future<String?> getCsrfToken();
  Future<bool>    hasToken();
  Future<void>    clearAll();
}
```

### 5.6 `core/storage/local_storage.dart`

`LocalStorageService` (rename of `Preferences`). GetStorage-backed. Sync getters, async setters.

Generic API:
```dart
Future<bool> setString(String key, String value);
String?      getString(String key);
Future<bool> setBool(String key, bool value);
bool?        getBool(String key);
Future<bool> setInt(String key, int value);
int?         getInt(String key);
Future<bool> remove(String key);
Future<bool> clear();
Future<void> init();
```

Named accessors (skeleton-relevant only — happypet's project-specific ones like `clockInStatus`/`branchId` are NOT included):
```dart
String? get userDataJson;
Future<bool> saveUserData(String json);
Future<bool> clearUserData();

String get deviceId;
String get deviceType;
String get deviceToken;
String get deviceName;
Future<void> saveDeviceInfo({...});
```

### 5.7 `core/controllers/auth_controller.dart`

```dart
class AuthController extends GetxController {
  AuthController(AuthRepository repo);

  final user           = Rxn<UserModel>();
  final loginResponse  = Rxn<LoginResponse>();

  bool get isAuthenticated;       // user.value != null

  @override void onInit();        // calls checkAuth()
  Future<void> checkAuth();
  void applyLoginResponse(LoginResponse response);
  Future<void> logout({String? deviceId});
}
```

### 5.8 `core/routing/`

- `route_names.dart`: `abstract class RouteNames` with `splash`, `login`, `forgotPassword`, `home` (placeholder).
- `app_pages.dart`: `abstract class AppPages { static final List<GetPage> pages = [...]; }` — single source of truth.
- `auth_middleware.dart`: `GetMiddleware.redirect` returns `RouteSettings(name: RouteNames.login)` when `!Get.find<AuthController>().isAuthenticated`.

### 5.9 `core/di/initial_binding.dart`

```dart
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Storage (permanent)
    Get.put(SecureStorageService(), permanent: true);
    Get.put(LocalStorageService(), permanent: true);

    // Device + Network (lazy, fenix)
    Get.lazyPut(() => DeviceInfoService(Get.find()), fenix: true);
    Get.lazyPut(() => ApiClient(Get.find()), fenix: true);

    // Auth (lazy DS+Repo, permanent Controller)
    Get.lazyPut(() => AuthRemoteDataSource(Get.find()), fenix: true);
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find(), Get.find(), Get.find()),
      fenix: true,
    );
    Get.put(AuthController(Get.find()), permanent: true);
  }
}
```

### 5.10 `core/enums/view_state.dart`

```dart
enum ViewState { idle, loading, success, error, empty }
```

### 5.11 `shared/widgets/state_switch.dart`

```dart
class StateSwitch extends StatelessWidget {
  const StateSwitch({
    required this.state,
    this.onIdle,
    required this.onLoading,
    required this.onEmpty,
    required this.onError,
    required this.onSuccess,
  });

  final ViewState state;
  final WidgetBuilder? onIdle;
  final WidgetBuilder onLoading;
  final WidgetBuilder onEmpty;
  final WidgetBuilder onError;
  final WidgetBuilder onSuccess;
}
```

## 6. Naming conventions

| Item | Convention | Example |
|---|---|---|
| Files / dirs | `snake_case.dart` | `login_controller.dart` |
| Classes | `PascalCase` + suffix | `LoginController`, `LoginBindings`, `LoginView`, `AuthRepositoryImpl`, `AuthRemoteDataSource`, `UserModel` |
| Controller actions | `on*` returning `Future<bool>` | `onLogin`, `onResend`, `onRefresh` |
| Validators | `Validators.email` (static) or `*Validator` (mixin) | `Validators.password`, `emailValidator` |
| Form keys | `*FormKey` | `loginFormKey` |
| `TextEditingController` fields | `*Controller` | `emailController` |
| Routes | `RouteNames.camelCase` | `RouteNames.login`, `RouteNames.forgotPassword` |
| Env keys | `SCREAMING_SNAKE` in `.env` | `BASE_URL_STAGING`, `EP_LOGIN`, `ENABLE_LOGGING` |
| Storage keys | private `_camelCase` constants inside `LocalStorageService` | `_userDataKey` |
| Dimension tokens | `spacing<N>`, `radius<N>` | `AppDimensions.spacing16`, `AppDimensions.radius8` |
| Typography tokens | `xs/sm/md/lg/...` + weight suffix | `AppTypography.smMedium` |
| Imports | `package:app_structure/...` across folders; relative only within same screen folder | enforced by `always_use_package_imports` |

## 7. `.claude/` rule updates

| File | Change |
|---|---|
| `.claude/rules/error-handling.md` | **Rewrite.** Drop all `Result`/`Failure`/`.when()` language. New text: DataSource throws on `!response.success`; Repository try/catch + rethrow; Controller try/catch + set `state.value`/`errorMessage.value` + optional `AppSnackBar`; View branches via `StateSwitch`. Keep "no `BuildContext` across `await` in controllers" rule. |
| `.claude/rules/code-quality.md` | Add: never inline `Color(0xFF…)`, raw spacing/radius numbers, or `TextStyle(...)`. Use `AppColors`, `AppDimensions`, `AppTypography` / `AppText` instead. Update suffix list to include `*Model`, `*Bindings`; drop entity-suffix mention. |
| `.claude/rules/security.md` | Update: tokens MUST go through `SecureStorageService` (never `LocalStorageService`/`GetStorage`). CSRF on `POST/PUT/PATCH/DELETE` is automatic via `AuthInterceptor`. Refresh token flow lives in `TokenRefreshInterceptor` — never call refresh manually. |
| `.claude/rules/testing.md` | Add: mock `XRepository` interfaces only, never the impl or datasource. `Get.testMode = true` + `Get.put<XRepository>(MockRepo())` in test setup. |
| `.claude/rules/architecture.md` (new) | One short file pinning the layer contract + boot order. |
| `CLAUDE.md` | Replace "Architecture rule" sentence — drop Result/Failure language; new wording covers Model-as-the-type + Exception flow + ViewState. Replace GetX gotchas §1 to point at `core/di/initial_binding.dart`. Add a line about `StateSwitch` + `ViewState` as the single UI-state pattern. |

## 8. Testing

### 8.1 `test/` layout

```
test/
  core/
    network/
      api_client_test.dart
      token_refresh_interceptor_test.dart
    utils/
      validators_test.dart
      string_utils_test.dart
      date_utils_test.dart
  features/
    auth/
      data/
        auth_repository_impl_test.dart
      presentation/
        login_controller_test.dart
```

### 8.2 What to test per layer

| Layer | Test type | Assertions | NOT |
|---|---|---|---|
| `Validators` / `*Utils` | pure unit | input → output truth tables | — |
| `ApiClient` | unit w/ `DioAdapter` | `ApiResponse` shape on 2xx/4xx/5xx/DioException; `versionedPath` formatting | network behaviour |
| `TokenRefreshInterceptor` | unit | single-flight refresh, queue drain, no-loop-on-refresh-endpoint | log output |
| `AuthRepositoryImpl` | unit | side effects (SecureStorage/LocalStorage writes), rethrow shape | datasource internals |
| `XController` | unit w/ mocked `XRepository` | `state.value` transitions, `errorMessage.value`, `isLoading`, return `bool` | mock call counts |
| `XView` (optional) | widget | `StateSwitch` shows skeleton/empty/error/content per state | controller internals |

### 8.3 Mock strategy

- Mock the `domain/` interface; never the impl or the datasource.
- Use `mocktail` (no codegen, less ceremony than mockito).
- Shared `test/_helpers/test_bootstrap.dart` resets GetX with `Get.testMode = true`.

## 9. Verification — definition of done

The migration is complete when:

1. `make verify` exits 0 (`flutter pub get` + `dart fix --apply` + `dart format --set-exit-if-changed` + `dart analyze` + `flutter test`).
2. `flutter pub deps` shows `flutter_secure_storage` added and no orphaned packages.
3. App boots to the login screen on a clean install (no stored token) in `dev` environment without throwing.
4. Login with valid credentials reaches the placeholder home route and the username renders.
5. Forced 401 (wipe the token via DevTools, call any endpoint) triggers the refresh interceptor — verified via debug log containing `[TokenRefresh] refresh succeeded` (or `propagating` on intentional failure).
6. `flutter run --release` builds successfully.
7. Cold-start budget: under v2's current cold-start + 500 ms (Firebase init is the only added eager cost).
8. Spec self-review pass (placeholder/contradiction/ambiguity/scope check).

A new `make verify` Makefile target wraps the chain (`pub get → fix → lint → test`).

## 10. CI signal

Skeleton ships `.github/workflows/verify.yml.example` (NOT `.yml` — consumers opt in by renaming):

```yaml
on: [push, pull_request]
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: <pinned to pubspec.yaml SDK constraint>
      - run: flutter pub get
      - run: make verify
```

## 11. Out of scope

The following are explicitly **NOT** included in this work:

- Any happypet business feature (bookings, customers, inventory, clinic, invoices, reports, staff_flow, etc.).
- happypet's `branch_controller`, `notification_controller`, `groomer_location_service`, `permission_utils` / `PermissionGuard` / `PermModule` (project-specific RBAC).
- happypet's web-grade widgets (`AppTable`, `AppBreadcrumb`, `PageScaffold`, `AppHeader`, `SidebarMenuConfig`) — too admin-dashboard-specific for a generic mobile skeleton.
- happypet's `AppSnack`/`AppToast` — replaced by keeping v2's `AppSnackBar`.
- happypet's `AppTypography` GoogleFonts dependency — replaced with bundled OpenSans.
- happypet's `AppDateUtils.timeAgo` localisation — kept English-only; consumers add `intl` localisation as needed.

## 12. Goal traceability

| Goal | Served by |
|---|---|
| Fast cold start | GetStorage backend (sync after init), `lazyPut+fenix` for everything except the small permanent set, no `Result` wrapping overhead. Firebase eager init adds ~200–400 ms vs current v2 (accepted trade). |
| Less code per feature | Entity layer dropped (~2 files + mapping removed per feature). Flat folder layout. `ApiClient.get<T>(path, fromJson: T.fromJson)` is one line per call. `StateSwitch` removes per-screen loading/empty/error boilerplate. |
| Reusable across projects | Every new file is generic. Zero business names. Auth example is the minimum viable demo of every pattern — copy `features/auth/` and rename. |
| Easy API calls | `final res = await _api.get<UserModel>(ApiUrls.userDetails, fromJson: UserModel.fromJson);` — entire datasource line. Compare to v2 today: `request(...).then((r) => r.when(...))` — gone. |
| Predictable UI states | `ViewState` enum + `StateSwitch` widget. Every controller exposes the same 3 Rx (`state`, `errorMessage`, typed data). Every view branches the same way. |
| Performance | Long-lived `Dio` (one instance, interceptors attached once). `Get.lazyPut(fenix: true)` lets idle features sit at zero cost. Token refresh queues + retries on 401 instead of forcing re-login. `const` widgets enforced via existing lints. |

## 13. Rollback

If the migration breaks something irrecoverably mid-flight:

1. The work happens on a feature branch (NOT `main`).
2. Each phase of the implementation plan (storage swap, network swap, auth rewrite, widgets, deletions) is a separate commit.
3. Rollback = `git reset --hard <commit-before-bad-phase>` on the feature branch.
4. `main` is never touched until `make verify` passes and a manual smoke (login, forced 401, logout) is clean.

---

**End of design spec.** Implementation plan to follow (separate doc generated by writing-plans skill).
