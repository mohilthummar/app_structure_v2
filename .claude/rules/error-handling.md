---
paths:
  - "lib/features/**/data/**"
  - "lib/features/**/presentation/**"
  - "lib/core/network/**"
  - "lib/core/controllers/**"
---

# Error Handling

This project handles errors in **layers** — never collapse them.

- **DataSource** (`*_remote_datasource.dart`): calls `ApiClient.{get,post,put,patch,delete,uploadFile}` and receives `ApiResponse<T>`. On `!response.success` (or any `DioException` already mapped to `ApiErrorModel` by `ApiClient`), `throw Exception(response.error?.message ?? '<fallback>')`. Never return an `ApiResponse` upward.
- **Repository impl** (`*_repository_impl.dart`): wraps the datasource call in `try/catch` and rethrows as `Exception(e.toString())`. Persists side-effects (tokens via `SecureStorageService`, profile JSON via `LocalStorageService`) inside the impl. `logout()` is the one allowed exception swallower — local cleanup must run even if the API call failed.
- **Controller**: only `try/catch`. Set `state.value = ViewState.error`, `errorMessage.value = e.toString()`, and optionally `AppSnackBar.error(message: e.toString())`. Controllers must NOT import `ApiResponse`, `ApiErrorModel`, `BaseResponse`, or anything from `data/` other than the `*Model` types that flow through them.
- **View**: doesn't handle errors directly. Branches on `controller.state.value` via the `StateSwitch` widget (`onLoading`/`onEmpty`/`onError`/`onSuccess` builders). No raw try/catch in views.

Other rules:

- Never silently swallow an exception (`catch (_) {}`). Allowed exceptions: `AuthRepositoryImpl.logout` (API failure tolerated, local cleanup always runs) and `AuthController.logout` (teardown errors tolerated).
- Always set `state.value` in BOTH success and failure paths. The established pattern: `state.value = ViewState.loading` at the top, `success` or `error` in the respective branches.
- Cancel `StreamSubscription`s in `onClose()` (`cancel_subscriptions` lint). Close `StreamController`s too (`close_sinks`).
- `DioException` is mapped to user-safe strings by `ApiErrorModel.fromDioException` inside `ApiClient`. Never display a raw `DioException` to users — its message leaks base URLs, headers, and internal paths.
- `BuildContext` never crosses an `await` in a controller. Controllers return `Future<bool>`; views gate post-await UI on `if (context.mounted && ok) ...`.
- Tokens belong in `SecureStorageService` only — never `LocalStorageService`. CSRF + token refresh are automatic via the interceptor stack; do not call refresh manually.
