# Skeleton Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor `app_structure_v2` to adopt happypet-inspired infrastructure (`ApiClient`, `SecureStorage`, `AuthController`, `ViewState`, design tokens, generic widgets) while keeping it a generic Flutter skeleton.

**Architecture:** GetX-based Clean Architecture, model-as-the-type (no entity layer), strict layer boundaries (controller ↔ Repository interface only). Long-lived `Dio` + interceptor stack. ViewState + StateSwitch for predictable UI. See spec at `docs/superpowers/specs/2026-05-21-skeleton-update-from-happypet-design.md`.

**Tech Stack:** Flutter 3.8.1+, Dart 3.8.1+, GetX 4.7, Dio 5.9, get_storage 2.1, flutter_secure_storage 9.x, flutter_screenutil 5.9, Firebase Core 4.1 + Messaging 16.0.

**Execution order:** phases are dependency-ordered — do not skip ahead. Each task commits independently for safe rollback.

---

## Phase 0 — Setup

### Task 0.1: Verify branch and create checkpoint

- [ ] Run `git status && git branch --show-current`. Confirm working tree is clean (only the spec from prior commit) and branch is NOT `main`.
- [ ] If on `main`, create feature branch: `git checkout -b feat/skeleton-update`.
- [ ] Tag rollback point: `git tag pre-skeleton-update`.

### Task 0.2: Add `flutter_secure_storage` dependency

- [ ] Add `flutter_secure_storage: ^9.2.4` under the `# Firebase` section in `pubspec.yaml`.
- [ ] Run `flutter pub get`.
- [ ] Commit: `git add pubspec.yaml pubspec.lock && git commit -m "deps: add flutter_secure_storage for token storage"`

---

## Phase 1 — Foundation: constants, enums, env

### Task 1.1: Add `ViewState` enum

- [ ] Create `lib/core/enums/view_state.dart`:
  ```dart
  /// Predictable UI state for every controller. Views branch via StateSwitch.
  enum ViewState { idle, loading, success, error, empty }
  ```
- [ ] Commit: `feat(core): add ViewState enum for predictable UI states`

### Task 1.2: Add `environment_enums.dart`, replace inline enum

- [ ] Create `lib/core/enums/environment_enums.dart` with `EnvironmentType { local, development, staging, production }` carrying `id`/`label`/`slug` + `fromSlug` factory.
- [ ] If `common_enums.dart` declares `EnvironmentType`, remove that declaration only.
- [ ] Rewrite `lib/core/enums/enums.dart`:
  ```dart
  export 'common_enums.dart';
  export 'environment_enums.dart';
  export 'view_state.dart';
  ```
- [ ] Commit: `refactor(core): split EnvironmentType into environment_enums.dart`

### Task 1.3: Add common UI enums

- [ ] Append to `lib/core/enums/common_enums.dart`: `ButtonVariant`, `ToastType`, `ModalVariant`, `InputSize`, `CheckboxSize`.
- [ ] Commit: `feat(core): add ButtonVariant/ToastType/ModalVariant/InputSize/CheckboxSize`

### Task 1.4: Rename `constants.dart` → `app_constants.dart`

- [ ] `grep -rn "core/constants/constants" lib/ test/`
- [ ] Create `lib/core/constants/app_constants.dart` (preserve old top-level constants + add `AppConstants` class with `tokenKey`, `refreshTokenKey`, `csrfTokenKey`, `csrfHeaderName`, `connectTimeout`, `receiveTimeout`, `searchDebounce`, `defaultPageLimit`).
- [ ] Delete old `constants.dart`. Update importers.
- [ ] Commit: `refactor(core): rename constants.dart -> app_constants.dart`

### Task 1.5: Add `webOrigin` to `AppEnvironment`

- [ ] Add static `webOrigin` getter + private `_getWebOrigin()` that switches on `EnvironmentType` and reads `APP_WEB_ORIGIN_*` from env.
- [ ] Commit: `feat(env): add webOrigin getter`

### Task 1.6: Rename `api_url.dart` → `api_urls.dart`

- [ ] `grep -rn "config/api_url" lib/ test/`
- [ ] Create `lib/core/config/api_urls.dart` (`class ApiUrls`, with `apiV1`/`apiV2` constants + auth endpoints: `login`, `logout`, `refreshToken`, `forgotPassword`, `verifyToken`, `userDetails`). Preserve other existing endpoints.
- [ ] Delete old `api_url.dart`. Update importers.
- [ ] Commit: `refactor(config): rename api_url.dart -> api_urls.dart`

---

## Phase 2 — Storage

### Task 2.1: Create `SecureStorageService`

- [ ] Create `lib/core/storage/secure_storage.dart` (FlutterSecureStorage-backed; methods: `saveToken`/`getToken`, `saveRefreshToken`/`getRefreshToken`, `saveCsrfToken`/`getCsrfToken`, `hasToken`, `clearAll`).
- [ ] Commit: `feat(storage): add SecureStorageService`

### Task 2.2: Rename `Preferences` → `LocalStorageService`

- [ ] `grep -rn "core/storage/preferences\|Preferences\." lib/ test/`
- [ ] Create `lib/core/storage/local_storage.dart` (GetStorage-backed `LocalStorageService` with sync generic accessors + named accessors for `userDataJson`/`deviceId`/`deviceType`/`deviceToken`/`deviceName` + `saveModel<T>`/`getModel<T>` helpers).
- [ ] Delete `preferences.dart`. Update importers (use `Get.find<LocalStorageService>().x` pattern).
- [ ] Call sites using `Preferences.token` stay broken — Phase 7 rewrites the auth flow with `SecureStorageService` instead.
- [ ] Commit: `refactor(storage): rename Preferences -> LocalStorageService`

---

## Phase 3 — Network

### Task 3.1: Create `ApiErrorModel`

- [ ] Copy `/Users/doko/Downloads/happypet-flutter-development/lib/shared/models/api_error_model.dart` verbatim to `lib/shared/models/api_error_model.dart`. No app-specific edits (depends only on `dio`).
- [ ] Commit: `feat(shared): add ApiErrorModel`

### Task 3.2: Create `PaginationModel<T>`

- [ ] Copy `/Users/doko/Downloads/happypet-flutter-development/lib/shared/models/pagination_model.dart` verbatim. Depends only on Flutter foundation.
- [ ] Commit: `feat(shared): add PaginationModel<T>`

### Task 3.3: Create `ApiResponse<T>`

- [ ] Create `lib/core/network/api_response.dart` with `ApiResponse<T>` (fields `success`, `data`, `message`, `error`; factories `fromSuccess`, `fromError`).
- [ ] Commit: `feat(network): add ApiResponse<T>`

### Task 3.4: Create `AuthInterceptor`

- [ ] Create `lib/core/network/auth_interceptor.dart`. `onRequest`: attach Bearer from `SecureStorageService.getToken()`; for `POST/PUT/PATCH/DELETE`, attach `AppConstants.csrfHeaderName` from `getCsrfToken()`.
- [ ] Commit: `feat(network): add AuthInterceptor`

### Task 3.5: Create `TokenRefreshInterceptor`

- [ ] Copy happypet's `token_refresh_interceptor.dart` verbatim. Adjust import prefix `happypet_gms` → `app_structure`. Verify imports resolve.
- [ ] Commit: `feat(network): add TokenRefreshInterceptor (single-flight, queued)`

### Task 3.6: Create `ApiClient`

- [ ] Copy happypet's `api_client.dart` verbatim. Adjust import prefix `happypet_gms` → `app_structure`.
- [ ] Commit: `feat(network): add ApiClient`

### Task 3.7: Delete old network files

- [ ] `grep -rn "client_service\|base_response\|header_builder\|core/network/interceptor\|core/types/result\|Result<\|Failure<\|Success<\|BaseResponse" lib/ test/` — note breakage.
- [ ] `git rm lib/core/network/client_service.dart lib/core/network/base_response.dart lib/core/network/header_builder.dart lib/core/network/interceptor.dart lib/core/types/result.dart` and remove empty `lib/core/types/`.
- [ ] Compile-broken call sites stay broken until Phase 7. Confirm errors are isolated to the old auth files.
- [ ] Commit: `refactor(network): drop ClientService/BaseResponse/HeaderBuilder/Interceptor/Result`

---

## Phase 4 — Theme tokens

### Task 4.1: Expand `app_colors.dart`

- [ ] Read current `app_colors.dart` — note every existing token (views depend on them).
- [ ] Append happypet's tokens (orange25–900, gray25–900, status, toast, accents) from `/Users/doko/Downloads/happypet-flutter-development/lib/core/theme/app_colors.dart`. Keep existing v2 tokens unchanged. On collision, suffix the new one with `Alt`.
- [ ] Add `primarySwatch` getter if absent.
- [ ] Commit: `feat(theme): expand AppColors with happypet design tokens`

### Task 4.2: Create `AppDimensions`

- [ ] Copy happypet's `app_dimensions.dart` verbatim. Adjust import prefix. Tokens stay plain `double` — callers add `.h`/`.w`/`.r` from screenutil at call site.
- [ ] Commit: `feat(theme): add AppDimensions`

### Task 4.3: Create `AppTypography` (OpenSans, not GoogleFonts)

- [ ] Create `lib/core/theme/app_typography.dart` using `fontFamily: 'OpenSans'` (NO `google_fonts` import). Tokens: `xxs/xs/sm/md/base/lg/xl/text2xl` + weight helpers `regular/medium/semibold/bold` + presets `xsMedium/smMedium/mdMedium/lgSemibold/xlSemibold`.
- [ ] Commit: `feat(theme): add AppTypography (OpenSans)`

### Task 4.4: Rewire `AppText` widget

- [ ] In `lib/core/theme/app_text.dart`, replace `textStyle` getter so each `TextSize` value maps to the matching `AppTypography` token; apply `.sp` scaling on the size at the call site of `copyWith`.
- [ ] Add `import 'package:app_structure/core/theme/app_typography.dart';`. Remove obsolete `Theme.of(...)` reads.
- [ ] Commit: `refactor(theme): rewire AppText to AppTypography tokens`

### Task 4.5: Drop `app_style.dart`, rewrite `app_theme.dart`

- [ ] `grep -rn "core/theme/app_style\|defaultPadding\|defaultRadius\|AppRadius\|AppEdgeInsets" lib/ test/` — update each caller to use `AppDimensions` equivalents (e.g. `defaultPadding` → `AppDimensions.spacing14.h`).
- [ ] Delete `app_style.dart`.
- [ ] Rewrite `app_theme.dart` using `AppDimensions` + `AppTypography` (OpenSans family). Keep dark theme stub.
- [ ] Commit: `refactor(theme): drop app_style, rewrite app_theme with tokens`

### Task 4.6: Refactor `AppSnackBar` to tokens

- [ ] Replace inline `Color(0xFF...)` with `AppColors.toastSuccess/error/warning/infoBg/...` (add new tokens to AppColors only if necessary).
- [ ] Replace inline `10` borderRadius with `AppDimensions.radius10`.
- [ ] Public API unchanged.
- [ ] Commit: `refactor(utils): AppSnackBar uses tokens`

---

## Phase 5 — Core utilities

### Task 5.1: Add `Validators`

- [ ] Copy happypet's `validators.dart` verbatim to `lib/core/utils/validators.dart`. No edits.
- [ ] Commit: `feat(utils): add Validators`

### Task 5.2: Add `string_utils.dart`

- [ ] Copy happypet's `string_utils.dart` verbatim (top-level `prettyType` function).
- [ ] Commit: `feat(utils): add prettyType`

### Task 5.3: Add `date_utils.dart`

- [ ] Copy happypet's `date_utils.dart` verbatim (`AppDateUtils`).
- [ ] Commit: `feat(utils): add AppDateUtils`

### Task 5.4: Add `file_utils.dart`

- [ ] Copy happypet's `file_utils.dart` verbatim (`FileUtils`).
- [ ] Commit: `feat(utils): add FileUtils`

### Task 5.5: Back `ValidationMixin` with `Validators`

- [ ] In `lib/core/mixins/validation_mixin.dart`, replace each method body with `Validators.xxx` call. Keep mixin signatures.
- [ ] Commit: `refactor(mixins): back ValidationMixin with Validators`

---

## Phase 6 — Shared widgets

### Task 6.1: Create `StateSwitch`

- [ ] Create `lib/shared/widgets/state_switch.dart` with `class StateSwitch extends StatelessWidget`, switching on `ViewState` to call one of `onIdle?`/`onLoading`/`onEmpty`/`onError`/`onSuccess`.
- [ ] Commit: `feat(widgets): add StateSwitch`

### Task 6.2: Create `AppLoading`, `AppEmptyState`, `AppSkeleton`

- [ ] Create three files using `AppColors`, `AppDimensions`, `AppTypography`. `AppSkeleton` uses the `shimmer` package from pubspec.
- [ ] Commit: `feat(widgets): add Loading/Empty/Skeleton`

### Task 6.3: Create Checkbox/Switch/Radio/Chip/TabBar/Modal

- [ ] Create six widgets in `lib/shared/widgets/`. Each ~30–60 LOC, themed with `AppColors` + tokens, using corresponding `common_enums` enum where applicable.
- [ ] Commit: `feat(widgets): add Checkbox/Switch/Radio/Chip/TabBar/Modal`

### Task 6.4: Refactor `AppButton` with `ButtonVariant`

- [ ] Rewrite to accept `ButtonVariant variant` (contained/outlined/light/dashed/text). Use `AppDimensions.buttonPadding`/`borderRadius8`, `AppTypography.smMedium`, `AppColors.orange400`. Add `isLoading` and `onPressed: Future<void> Function()?` params.
- [ ] Commit: `refactor(widgets): AppButton ButtonVariant + tokens`

### Task 6.5: Refactor `AppTextField`

- [ ] Rewrite to use `AppDimensions.inputHeight/inputPadding`, `AppTypography.sm`, status borders. Keep existing public params; add `errorText`/`maxLength`/`suffixIcon`.
- [ ] Commit: `refactor(widgets): AppTextField tokens`

### Task 6.6: Refactor `AppDropdown`

- [ ] Rewrite `app_drop_down.dart` with `AppDropdown<T>({required List<T> items, required T? value, required ValueChanged<T?> onChanged, String? errorText, String? hintText, String Function(T)? labelBuilder})` using `dropdown_button2` package.
- [ ] Commit: `refactor(widgets): AppDropdown generic API`

### Task 6.7: Delete duplicate `app_animated_cliprect.dart`

- [ ] `grep -rn "shared/widgets/app_animated_cliprect" lib/ test/`
- [ ] Update callers to use `shared/packages/app_animated_cliprect.dart`. `git rm lib/shared/widgets/app_animated_cliprect.dart`.
- [ ] Commit: `chore(widgets): remove duplicate app_animated_cliprect`

---

## Phase 7 — Auth domain + data

### Task 7.1: Drop entity `user.dart`

- [ ] `grep -rn "features/auth/domain/user\|class User\b" lib/ test/`
- [ ] `git rm lib/features/auth/domain/user.dart`.
- [ ] Commit: `refactor(auth): drop User entity`

### Task 7.2: Rewrite `UserModel` (remove `toEntity()`)

- [ ] Remove `toEntity()` method. Add `copyWith()` if missing. Keep `fromJson`/`toJson`/fields.
- [ ] Commit: `refactor(auth): UserModel no longer needs toEntity`

### Task 7.3: Create `LoginRequest` + `LoginResponse`

- [ ] Create `lib/features/auth/data/login_request.dart` (`email`, `password`, optional `deviceInfo`; `toJson`).
- [ ] Create `lib/features/auth/data/login_response.dart` (`user: UserModel?`, `accessToken`/`refreshToken`/`message`; `fromJson` handling `data.tokens.{access,refresh}.token` and flat `accessToken`/`refreshToken` shapes).
- [ ] Commit: `feat(auth): add LoginRequest + LoginResponse`

### Task 7.4: Rewrite `AuthRepository` interface

- [ ] Replace `lib/features/auth/domain/auth_repository.dart` with abstract class declaring: `login`, `forgotPassword`, `logout`, `isAuthenticated`, `getStoredUser`.
- [ ] Commit: `refactor(auth): rewrite AuthRepository interface`

### Task 7.5: Rewrite `AuthRemoteDataSource`

- [ ] Replace `lib/features/auth/data/auth_remote_datasource.dart` with `ApiClient`-based class. Methods: `login(LoginRequest) → LoginResponse`, `forgotPassword(email) → void`, `logout(deviceId) → void`. Throws `Exception(res.error?.message ?? '<default>')` on `!res.success`.
- [ ] Commit: `refactor(auth): rewrite AuthRemoteDataSource`

### Task 7.6: Rewrite `AuthRepositoryImpl`

- [ ] Replace `lib/features/auth/data/auth_repository_impl.dart`:
  - `login`: call DS, `_persist(response)`, return; rethrow on error.
  - `forgotPassword`: call DS; rethrow on error.
  - `logout`: tolerate DS failure, always clear secure storage + user data.
  - `isAuthenticated`: `_secure.hasToken()`.
  - `getStoredUser`: parse `_local.userDataJson` → `UserModel`.
  - `_persist(LoginResponse)`: save tokens to SecureStorage, save user JSON to LocalStorage.
- [ ] Commit: `refactor(auth): rewrite AuthRepositoryImpl`

---

## Phase 8 — Global `AuthController`

### Task 8.1: Create `AuthController`

- [ ] Create `lib/core/controllers/auth_controller.dart`:
  - `user = Rxn<UserModel>()`, `loginResponse = Rxn<LoginResponse>()`
  - `isAuthenticated => user.value != null`
  - `onInit` → `checkAuth()`
  - `checkAuth`: if `isAuthenticated()`, `user.value = await getStoredUser()`
  - `applyLoginResponse(response)`: set both Rxn
  - `logout({deviceId})`: try repo logout, clear state, `Get.offAllNamed(RouteNames.login)`, `Future.delayed(Duration.zero)`, `Get.deleteAll(force: false)`
- [ ] File will not compile until Phase 9 lands `RouteNames.login` — that's expected.
- [ ] Commit: `feat(auth): add global AuthController`

---

## Phase 9 — Routing

### Task 9.1: `route_names.dart`

- [ ] Create `lib/core/routing/route_names.dart`:
  ```dart
  abstract class RouteNames {
    static const splash = '/splash';
    static const login = '/login';
    static const forgotPassword = '/forgot-password';
    static const home = '/home';
  }
  ```
- [ ] Commit: `feat(routing): add RouteNames`

### Task 9.2: `auth_middleware.dart`

- [ ] Create `lib/core/routing/auth_middleware.dart`: `GetMiddleware.redirect` returning `RouteSettings(name: RouteNames.login)` when not authenticated.
- [ ] Commit: `feat(routing): add AuthMiddleware`

### Task 9.3: `app_pages.dart` + delete old `routes/`

- [ ] Create `lib/core/routing/app_pages.dart`: `abstract class AppPages` with `static final List<GetPage> pages = [splash, login, forgotPassword, home(placeholder, middleware: AuthMiddleware)]`. File won't compile until Phase 10 lands login/forgot views — expected.
- [ ] `grep -rn "routes/routes\|RoutesName" lib/ test/` — update each importer (`pages` → `AppPages.pages`, `RoutesName.splashView` → `RouteNames.splash`, etc.).
- [ ] `git rm lib/routes/routes.dart lib/routes/routes_name.dart && rmdir lib/routes`.
- [ ] Commit: `refactor(routing): move routes/ -> core/routing/`

---

## Phase 10 — Auth presentation

### Task 10.1: Delete `sign_in/` + `sign_up/`

- [ ] `grep -rn "sign_in_view\|sign_up_view\|SignInView\|SignUpView\|SignInBindings\|SignUpBindings\|SignInController\|SignUpController" lib/ test/`
- [ ] `git rm -r lib/features/auth/presentation/sign_in lib/features/auth/presentation/sign_up`.
- [ ] Commit: `refactor(auth): remove sign_in/ + sign_up/`

### Task 10.2: Rewrite `splash`

- [ ] Rewrite `splash_controller.dart`: in `onReady`, await `AuthController.checkAuth()`, then `Get.offAllNamed(isAuthenticated ? home : login)`.
- [ ] Rewrite `splash_bindings.dart`: `Get.lazyPut(() => SplashController())`.
- [ ] Verify `splash_view.dart` imports compile (remove old `RoutesName` refs).
- [ ] Commit: `refactor(auth/splash): use global AuthController`

### Task 10.3: Create `login/`

- [ ] Create `login_bindings.dart`: `Get.lazyPut(() => LoginController(Get.find<AuthRepository>()))`.
- [ ] Create `login_controller.dart`:
  - Rx: `state`, `errorMessage`, `isPasswordHidden`
  - Form: `emailController`, `passwordController`, `loginFormKey`
  - `onLogin`: validate → loading → call repo.login → apply to AuthController → success + `Get.offAllNamed(home)`. Catch → error + AppSnackBar.
  - `onTogglePassword`, `onForgotPassword`, `onClose` disposes controllers.
- [ ] Create `login_view.dart`: `GetView<LoginController>` using `AppTextField` (email + password, password toggleable), `AppButton` with `isLoading` bound to `state == loading`, "Forgot password?" text button.
- [ ] Commit: `feat(auth/login): bindings/controller/view`

### Task 10.4: Create `forgot_password/`

- [ ] Three files mirroring login: bindings + controller (Rx `state`/`errorMessage`, `emailController`, `formKey`, `onSend` → repo.forgotPassword → success snack + `Get.back()`) + view (single email field + send button).
- [ ] Commit: `feat(auth/forgot-password): bindings/controller/view`

---

## Phase 11 — DI + DeviceInfo + Bootstrap + Main

### Task 11.1: Create `DeviceInfoService`

- [ ] Copy happypet's `device_info_service.dart` verbatim. Adjust prefix.
- [ ] Commit: `feat(services): add DeviceInfoService`

### Task 11.2: Create `InitialBinding`

- [ ] Create `lib/core/di/initial_binding.dart` registering in order: `SecureStorageService` (perm) → `LocalStorageService` (perm) → `DeviceInfoService` (lazy/fenix) → `ApiClient` (lazy/fenix) → `AuthRemoteDataSource` (lazy/fenix) → `AuthRepository`-as-`AuthRepositoryImpl` (lazy/fenix) → `AuthController` (perm).
- [ ] Commit: `feat(di): add InitialBinding`

### Task 11.3: Update `bootstrap.dart`

- [ ] Rewrite to: `WidgetsFlutterBinding.ensureInitialized()` → `dotenv.load` → `Firebase.initializeApp()` → `SystemUiOverlayStyle` → portrait orientation lock. Catch + `AppPrint.error`.
- [ ] Commit: `feat(bootstrap): add Firebase init + status bar style`

### Task 11.4: Update `main.dart`

- [ ] Rewrite to: `await bootstrap()` → `AppEnvironment.setEnvironment(EnvironmentType.development)` → `InitialBinding().dependencies()` → `await Get.find<LocalStorageService>().init()` → `runApp(MyApp())`.
- [ ] Commit: `refactor(main): wire InitialBinding + LocalStorage init`

### Task 11.5: Update `app.dart`

- [ ] Drop `LazyBinding` class. Use `AppPages.pages`, `RouteNames.splash`. Keep `ScreenUtilInit` + textScaler clamp.
- [ ] Commit: `refactor(app): drop LazyBinding, use AppPages + RouteNames`

---

## Phase 12 — Drop dead `core/base/`

### Task 12.1: Delete `core/base/`

- [ ] `grep -rn "core/base/\|BaseViewController\|OverlayController" lib/ test/` — remove any references.
- [ ] `git rm -r lib/core/base`.
- [ ] Commit: `chore(core): drop unused base/ folder`

---

## Phase 13 — `.claude/rules` updates

### Task 13.1: Rewrite `error-handling.md`

- [ ] Replace with the new layered contract: DataSource throws `Exception` on `!response.success`; Repo try/catch + rethrow; Controller sets `state.value/errorMessage.value` + optional snack; View branches via `StateSwitch`. Add no-BuildContext-across-await rule.
- [ ] Commit: `docs(rules): rewrite error-handling`

### Task 13.2: Update `security.md`

- [ ] Tokens MUST go through `SecureStorageService`. CSRF is automatic via `AuthInterceptor`. Refresh flow lives in `TokenRefreshInterceptor`.
- [ ] Commit: `docs(rules): security uses SecureStorage`

### Task 13.3: Update `code-quality.md`

- [ ] Forbid inline `Color(0xFF…)`, raw spacing/radius numbers, `TextStyle(...)` — use `AppColors`, `AppDimensions`, `AppTypography`/`AppText`. Update suffix list to include `*Model`, `*Bindings`.
- [ ] Commit: `docs(rules): forbid inline colors/sizes`

### Task 13.4: Update `testing.md`

- [ ] Mock `domain/` interfaces only. Use `mocktail`. `Get.testMode = true` + `Get.reset()`.
- [ ] Commit: `docs(rules): testing — mock interfaces`

### Task 13.5: Create `architecture.md`

- [ ] One-page summary of layer contract + boot order.
- [ ] Commit: `docs(rules): add architecture overview`

### Task 13.6: Update `CLAUDE.md`

- [ ] Replace Architecture rule paragraph with new wording covering Model-as-the-type + Exception flow + ViewState/StateSwitch.
- [ ] Replace GetX gotchas §1 to point at `core/di/initial_binding.dart`.
- [ ] Add line about every controller exposing `state` + `errorMessage`; views render via `StateSwitch`.
- [ ] Commit: `docs(claude.md): update architecture rule + GetX gotchas`

---

## Phase 14 — Makefile + verify

### Task 14.1: Add `make verify`

- [ ] Append a `verify` target to `Makefile` that runs: `flutter pub get && dart fix --apply && dart format --set-exit-if-changed . && dart analyze && flutter test`.
- [ ] Run `make verify` and iterate: fix every compile error (most are missing import updates from earlier renames). Loop until exit 0.
- [ ] Commit: `build: add make verify`

### Task 14.2: Smoke test

- [ ] `flutter run -d <device>`. Boot to splash → login. With valid `.env` and credentials, log in → home placeholder.
- [ ] Any runtime issues → fix in follow-up commits prefixed `chore: post-smoke`.

---

## Phase 15 — Final cleanup

### Task 15.1: `flutter pub deps` orphan check

- [ ] `flutter pub deps --no-dev --style=compact`. Confirm `flutter_secure_storage` present, no orphans.

### Task 15.2: Commit summary check

- [ ] `git log --oneline pre-skeleton-update..HEAD`. ~25–40 small commits expected.

---

**End of plan.**

Engineering note: verbatim copies (Tasks 3.1, 3.2, 3.5, 3.6, 4.2, 5.1–5.4, 11.1) require read access to `/Users/doko/Downloads/happypet-flutter-development/`. For each, change only `import 'package:happypet_gms/...'` → `import 'package:app_structure/...'`.

Common pitfalls:
- After deleting `core/network/client_service.dart` (Phase 3.7) and before Phase 7 lands, `flutter analyze` will be noisy. That's expected — DO NOT try to fix individual call sites; the Phase 7 rewrites replace them wholesale.
- `LazyBinding` is removed from `app.dart` in Phase 11.5 — any reference to `DeepLinkManager`/`BaseViewController` registration through `LazyBinding` is dropped. Consumers re-register as needed in their own `InitialBinding` extension.
- `AppText` widget's enum stays the same (`TextSize.small_12` etc.) so existing usages don't need updates — only the internal `textStyle` getter changes.
