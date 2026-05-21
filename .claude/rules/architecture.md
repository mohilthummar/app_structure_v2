---
alwaysApply: true
---

# Architecture

Single-page summary of the skeleton's shape. The authoritative design spec lives at `docs/superpowers/specs/2026-05-21-skeleton-update-from-happypet-design.md`.

## Boot flow (don't reorder)

`main.dart`:

1. `await bootstrap()` — dotenv load + `Firebase.initializeApp` + status bar + portrait lock
2. `AppEnvironment.setEnvironment(EnvironmentType.development)` — pick env (flip constant per build)
3. `InitialBinding().dependencies()` — wire DI graph
4. `await Get.find<LocalStorageService>().init()` — GetStorage warmup
5. `runApp(const MyApp())` — `GetMaterialApp` with `AppPages.pages` + `RouteNames.splash`

## Layer contract (per feature)

```
features/<name>/
  domain/<name>_repository.dart            # abstract interface ONLY
  data/<name>_remote_datasource.dart       # calls ApiClient → *Model; throws Exception on !success
  data/<name>_repository_impl.dart         # try/catch + rethrow; persists via SecureStorage/LocalStorage
  data/<name>_model.dart                   # fromJson + toJson + copyWith — used by ALL layers
  presentation/<screen>/
    <screen>_bindings.dart                 # Get.lazyPut DS → Repo → Controller (repo as INTERFACE)
    <screen>_controller.dart               # state: ViewState.idle.obs, errorMessage: ''.obs,
                                           # typed data Rx, on* methods returning Future<bool>
    <screen>_view.dart                     # GetView<XController>; renders via StateSwitch
```

**Rule:** controllers depend on the `domain/` interface only. `*Model` flows through all layers (no entity/DTO split). `ApiResponse<T>` stays inside the data layer.

## DI

- **Permanent** (`Get.put(..., permanent: true)` in `core/di/initial_binding.dart`): `SecureStorageService`, `LocalStorageService`, `AuthController`.
- **Lazy + fenix** (`Get.lazyPut(..., fenix: true)`): everything else, including `ApiClient`, `DeviceInfoService`, `AuthRemoteDataSource`, `AuthRepositoryImpl`.
- **Screen-scoped**: per-screen `Bindings` register the screen's DataSource → Repository → Controller with `Get.lazyPut`.
- Register repos as the **interface** (`Get.lazyPut<AuthRepository>(...)`), never the impl.

## Routing

- `core/routing/route_names.dart` — `abstract class RouteNames` constants. Single source of truth.
- `core/routing/app_pages.dart` — `AppPages.pages: List<GetPage>`. Single source of truth.
- `core/routing/auth_middleware.dart` — `GetMiddleware` reading `AuthController.isAuthenticated`. Protected routes list `middlewares: [AuthMiddleware()]`.

## Network

- `core/network/api_client.dart` — one long-lived `Dio` per app lifetime. Typed `get/post/put/patch/delete/uploadFile` returning `ApiResponse<T>`.
- `core/network/auth_interceptor.dart` — Bearer on every request, CSRF on mutating methods. Reads from `SecureStorageService`.
- `core/network/token_refresh_interceptor.dart` — single-flight 401 refresh with queued retries. **Never auto-logout**; callers decide via `AuthController.logout()`.

## UI state

- `core/enums/view_state.dart` — `enum ViewState { idle, loading, success, error, empty }`.
- `shared/widgets/state_switch.dart` — `StateSwitch` widget branches on `ViewState` to render loading / empty / error / success builders. Every screen uses this; never reinvent loading/empty/error UX per-screen.
