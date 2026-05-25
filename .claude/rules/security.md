---
paths:
  - "lib/features/auth/**"
  - "lib/core/network/**"
  - "lib/core/storage/**"
  - "lib/core/services/**"
  - "lib/core/config/**"
---

# Security

- Never commit `.env`. New keys land in `.env.example` (placeholder values only) and `.env` simultaneously.
- Never log tokens, OTPs, PII, or full request/response bodies. `enableLogging` from `.env` gates `pretty_dio_logger`; verify it's off for prod builds.
- Auth tokens belong in the Dio interceptor / request headers, never in URLs or query strings. Access, refresh, and CSRF tokens MUST go through `SecureStorageService` (`flutter_secure_storage`) — never `LocalStorageService`/`GetStorage`. `AuthInterceptor` attaches Bearer + CSRF automatically; `TokenRefreshInterceptor` runs the single-flight 401 refresh — don't call refresh manually.
- Treat every datasource response as untrusted: validate types and required fields in `fromJson` before constructing the entity. Don't pass raw `Map<String, dynamic>` past the data layer.
- Deep links (`DeepLinkService`) and push payloads (`NotificationService`) are user-controlled input. Both services drop non-whitelisted input by default:
  - `NotificationService(allowedTypes: { 'order', 'chat' })` — only payloads whose `type` field matches navigate further.
  - `DeepLinkService(allowedPaths: { '/order/', '/profile' })` — only path prefixes in the set produce a `DeepLinkIntent`.
  - Neither service navigates itself. Subscribe to `onTap` / `onLink` from a top-level coordinator (e.g. splash controller) and call `Get.toNamed` after validating any parameters.
- File picker / image picker results: validate MIME, size, and extension before upload. Strip EXIF on images that may contain location data.
- `PermissionService` (wrapping `permission_handler`): request the **narrowest** permission needed and only at the point of use. Don't request everything on launch. `PermissionOutcome.permanentlyDenied` → call `openSettings()` after a user gesture, never silently.
- Don't catch-and-display raw `DioException` messages — they can leak base URLs, headers, or internal paths. Map to user-safe strings in the repository impl.
- Webview / `url_launcher`: scheme-allowlist before launching (`https`, `tel`, `mailto`); never launch arbitrary user-supplied URLs without confirmation.
- Crashlytics: never call `CrashlyticsService.recordError` with raw request/response data. The `AppLogger.error(...)` → `errorReportHook` path strips nothing — keep token / PII out of the original log message.
- Analytics: event names and parameter values are visible in the Firebase dashboard. Use IDs, not free-form text — never log a user's email, phone, or address as a parameter value.
