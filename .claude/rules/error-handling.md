---
paths:
  - "lib/features/**/data/**"
  - "lib/features/**/presentation/**"
  - "lib/core/network/**"
---

# Error Handling

This project handles errors in **layers** — never collapse them.

- **DataSource** (`*_remote_datasource.dart`): receives `Result<BaseResponse, String>` from `ClientService`. Use `.when()`; on success return the entity (via `Model.fromJson(...).toEntity()`), on error `throw Exception(error)`. Never return a `Result` upward.
- **Repository impl** (`*_repository_impl.dart`): wraps the datasource call in `try/catch` and rethrows as `Exception(e.toString())`. Domain `Result<T>` from `core/types/` is folded **inside** the impl when present, never leaked out.
- **Controller**: only `try/catch`. Surface user-facing messages via `AppSnackBar.error(message: e.toString())` and toggle `isLoading.value`. Controllers must **not** import `Result`, `Failure`, `BaseResponse`, or anything from `data/`.
- **View**: doesn't handle errors directly. It awaits the controller's `Future<bool>` and conditionally shows UI (`if (context.mounted && ok) showDialog(...)`).

Other rules:

- Never silently swallow an exception (`catch (_) {}`). Either rethrow with context or surface to the user.
- Always reset loading state in **both** success and failure paths. The established pattern sets `isLoading.value = false` before the snackbar / navigation.
- `avoid_returning_null_for_future` is enforced — return `Future.value()` or nothing, never `null`.
- Cancel `StreamSubscription`s in `onClose()` (`cancel_subscriptions` lint). Close `StreamController`s too (`close_sinks`).
- `connectivity_service` and `Dio` errors should be mapped to user-readable strings at the repository boundary; raw `DioException` reaches users with internal hints (URLs, headers).
