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
- Auth tokens belong in the Dio interceptor / request headers, never in URLs or query strings. Refresh tokens, if any, go in secure storage (not raw `GetStorage`).
- Treat every datasource response as untrusted: validate types and required fields in `fromJson` before constructing the entity. Don't pass raw `Map<String, dynamic>` past the data layer.
- Deep links (`DeepLinkManager`) and push payloads are user-controlled input. Whitelist routes and parameter shapes before navigating; never `eval`-style execute.
- File picker / image picker results: validate MIME, size, and extension before upload. Strip EXIF on images that may contain location data.
- `permission_handler` prompts: request the **narrowest** permission needed and only at the point of use. Don't request all permissions on launch.
- Don't catch-and-display raw `DioException` messages — they can leak base URLs, headers, or internal paths. Map to user-safe strings in the repository impl.
- `flutter_local_notifications` / `firebase_messaging`: only deserialize `data` fields you control. Never act on a notification's intent string without validation.
- Webview / `url_launcher`: scheme-allowlist before launching (`https`, `tel`, `mailto`); never launch arbitrary user-supplied URLs without confirmation.
