# app_structure

Flutter app with clean architecture, GetX, and environment-based configuration.

## Prerequisites

- Flutter SDK ^3.8.1
- Dart ^3.8.1

## Getting Started

```bash
# Clone and enter project
cd app_structure_v2

# Install dependencies
flutter pub get

# Create .env from template (required for API base URL and endpoints)
make env-setup
# Then edit .env with your BASE_URL_* and endpoint paths

# Run the app
make run
# or: flutter run
```

**Important:** The app reads configuration from a `.env` file. Copy `.env.example` to `.env` (e.g. `make env-setup`) and fill in values. Never commit `.env`; it is in `.gitignore`.

## Project Structure

```
lib/
├── main.dart              # Entry: bootstrap → setEnvironment → runApp
├── bootstrap.dart         # Loads .env, WidgetsBinding, orientation, etc.
├── app.dart               # GetMaterialApp, routes, theme, LazyBinding
├── core/                   # Shared infrastructure
│   ├── base/              # BaseViewController, OverlayController
│   ├── config/            # AppEnvironment, ApiUrls (env-based)
│   ├── constants/        # app_colors, app_strings, app_assets, etc.
│   ├── enums/             # common_enums (EnvironmentType), enums
│   ├── extensions/       # number, date, currency
│   ├── network/           # ClientService (Dio), base_response, interceptor
│   ├── services/          # connectivity, notifications, deep_linking
│   ├── storage/           # Preferences (GetStorage)
│   ├── theme/             # app_theme, app_style, app_text
│   ├── types/             # Result<L, R>, Failure, Success
│   └── utils/             # validation_mixin, app_snack_bar, ui_utils, formatters
├── routes/
│   ├── routes.dart        # GetPage list, getPage helper
│   └── routes_name.dart   # Route name constants
├── shared/                 # Reusable across features
│   ├── models/            # e.g. DropDownModel
│   ├── widgets/           # app_button, app_text_field, screen_header, etc.
│   └── packages/          # country_code, country_state_city, etc.
└── features/
    └── auth/
        ├── domain/        # user.dart, auth_repository.dart (interface)
        ├── data/          # user_model.dart, auth_remote_datasource, auth_repository_impl
        └── presentation/
            ├── splash/   # splash_view, splash_controller, splash_bindings
            ├── sign_in/   # sign_in_view, sign_in_controller, sign_in_bindings
            ├── sign_up/   # sign_up_view, sign_up_controller, sign_up_bindings
            └── shared/   # otp_dialog.dart
```

## Environment and .env

- **Single .env file:** All environments use one `.env`; which base URL/keys are used is decided by `EnvironmentType` set in `main.dart`.
- **Load order:** `main.dart` calls `await bootstrap()` first (which loads `.env` via `flutter_dotenv`), then `AppEnvironment.setEnvironment(EnvironmentType.development)`, then `runApp()`. This ensures `baseUrl` and other env values are available when the app runs.
- **AppEnvironment** (`core/config/app_environment.dart`):
  - `setEnvironment(EnvironmentType)` — call once after bootstrap.
  - `baseUrl` — from `BASE_URL_LOCAL`, `BASE_URL_DEV`, `BASE_URL_STAGING`, or `BASE_URL_PROD` depending on type.
  - `enableLogging`, `enableCrashlytics` — from `.env` flags.
- **ApiUrls** (`core/config/api_url.dart`): Endpoint paths read from `.env` (e.g. `EP_SIGN_IN`, `EP_SIGN_UP`). Used by `AuthRemoteDataSource` and `ClientService`.
- **ClientService** (`core/network/client_service.dart`): Dio `baseUrl` is `AppEnvironment.baseUrl` + API version; timeouts and interceptors configured there.
- **pubspec.yaml:** `flutter_dotenv: ^6.0.0`; assets include `.env`.
- **.gitignore:** `.env` is ignored; `.env.example` is committed as a template.

To switch environment, change in `main.dart`:

```dart
AppEnvironment.setEnvironment(EnvironmentType.development); // or .local, .staging, .production
```

## Auth Flow (Sign In / Sign Up)

- **Controllers** do not use `BuildContext` after `await` (avoids “use BuildContext across async gaps”).
- **Sign-up:** `SignUpController.onSignUp()` returns `Future<bool>`. View awaits it, then if `context.mounted && shouldShowOtp` shows `OtpDialog`. OTP verify/resend and navigation (e.g. to sign-in) are in the controller.
- **Sign-in:** Same pattern — `SignInController.onSignIn()` returns `Future<bool>`; view shows OTP dialog only when `context.mounted && shouldShowOtp`.
- **Bindings:** `SignInBindings` / `SignUpBindings` register `AuthRemoteDataSource`, `AuthRepositoryImpl`, and the controller. Routes use these bindings.

## Routes

- **routes_name.dart:** Constants like `RoutesName.splashView`, `signInView`, `signUpView`.
- **routes.dart:** `pages` list of `GetPage` with name, page widget, and bindings. Initial route: `RoutesName.splashView` (`/`).

## Makefile

- **Run:** `make run`, `make run-release`, `make run-profile`
- **Env:** `make env-setup` — copies `.env.example` to `.env` if `.env` does not exist
- **Code quality:** `make format`, `make analyze`, `make lint`, `make fix`
- **Tests:** `make test`, `make test-file FILE=path/to/test.dart`
- **Maintenance:** `make get`, `make clean`, `make reset`, `make doctor`
- **Help:** `make help`

## Checklist (nothing missing)

- [x] `.env` loaded in `bootstrap()` before `setEnvironment` in `main.dart`
- [x] `AppEnvironment` and `ApiUrls` read from `dotenv`; `ClientService` uses `AppEnvironment.baseUrl`
- [x] `.env` in `pubspec.yaml` assets and in `.gitignore`; `.env.example` committed
- [x] Auth sign-in/sign-up return `bool`; views show OTP dialog with `context.mounted` check
- [x] Routes and bindings for splash, sign-in, sign-up; GetX bindings inject datasource → repository → controller
- [x] `make env-setup` to create `.env` from `.env.example`

For detailed architecture and naming conventions, see `.cursor/rules/flutter-architecture.mdc`.
