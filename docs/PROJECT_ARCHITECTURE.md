# Project Architecture

This is the single source of truth for the project's architecture, folder structure, naming conventions, coding patterns, and guidelines. Use this document to onboard developers, configure AI assistants, or review the codebase.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Folder Structure](#2-folder-structure)
3. [Layer Rules and Dependencies](#3-layer-rules-and-dependencies)
4. [Naming Conventions](#4-naming-conventions)
5. [Data Flow (How a Feature Works)](#5-data-flow-how-a-feature-works)
6. [Code Examples (Auth Feature)](#6-code-examples-auth-feature)
7. [Result and Error Handling](#7-result-and-error-handling)
8. [Dependency Injection](#8-dependency-injection)
9. [Barrel (Export) Files](#9-barrel-export-files)
10. [Import Rules](#10-import-rules)
11. [Adding a New Feature (Step-by-Step)](#11-adding-a-new-feature-step-by-step)
12. [Adding a New Screen to an Existing Feature](#12-adding-a-new-screen-to-an-existing-feature)
13. [Where to Put New Files (Quick Lookup)](#13-where-to-put-new-files-quick-lookup)
14. [State Management (GetX)](#14-state-management-getx)
15. [Mixins](#15-mixins)
16. [Best Practices](#16-best-practices)
17. [What NOT to Do](#17-what-not-to-do)

---

## 1. Architecture Overview

This project uses **Simplified Clean Architecture** with a **feature-first** approach and **GetX** for state management, routing, and dependency injection.

**Key principles:**

- Each feature has three layers: **domain**, **data**, **presentation**
- **Domain** is pure Dart — no Flutter, no GetX, no Dio, no JSON
- **Data** implements domain interfaces and handles API/network/storage
- **Presentation** contains UI, controllers, and bindings
- **Repository handles Result internally** — controller only receives data or catches exceptions
- **No use cases** — controller calls repository directly (simpler; add use cases later if needed)
- **Dependency injection via GetX bindings** — controller never creates a repository directly

**Dependency direction:**

```
Presentation ──depends on──> Domain <──implements── Data
                               |
                    depends on NOTHING
                  (pure Dart, no Flutter)
```

**Tech stack:**

- Flutter + Dart
- GetX (state management, DI, routing)
- Dio (HTTP client)
- Result pattern (domain-safe error handling)

---

## 2. Folder Structure

```
lib/
├── main.dart                        # App entry point
├── bootstrap.dart                   # App initialization (Firebase, storage, orientation)
├── app.dart                         # GetMaterialApp widget, global bindings
│
├── core/                            # Shared infrastructure (used by all features)
│   ├── base/                        # Base controllers
│   │   ├── base_view_controller.dart
│   │   └── overlay_controller.dart
│   ├── config/                      # Environment and API configuration
│   │   ├── app_environment.dart
│   │   └── api_url.dart
│   ├── constants/                   # App-wide constants
│   │   ├── app_assets.dart
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── constants.dart           # Barrel file
│   ├── enums/                       # App-wide enums
│   │   ├── common_enums.dart
│   │   └── enums.dart               # Barrel file
│   ├── extensions/                  # Dart extensions
│   │   ├── currency_extension.dart
│   │   ├── date_extension.dart
│   │   ├── number_extension.dart
│   │   └── extensions.dart          # Barrel file
│   ├── mixins/                      # Reusable mixins (validation, etc.)
│   │   ├── validation_mixin.dart
│   │   └── mixins.dart              # Barrel file
│   ├── network/                     # HTTP client and networking
│   │   ├── api_client.dart          # Concrete ClientService implementation
│   │   ├── client_service.dart      # Abstract HTTP service
│   │   ├── base_response.dart       # API response wrapper
│   │   ├── result.dart              # Network Result<S, F> (for HTTP layer)
│   │   ├── interceptor.dart         # Auth interceptor
│   │   └── header_builder.dart      # Request header builder
│   ├── services/                    # Core services (standalone)
│   │   ├── connectivity_service.dart
│   │   ├── deep_linking_manager.dart
│   │   └── notification_services.dart
│   ├── storage/                     # Local storage and preferences
│   │   ├── preferences.dart
│   │   └── storage.dart             # Barrel file
│   ├── theme/                       # App theme, styles, typography
│   │   ├── app_theme.dart
│   │   ├── app_style.dart
│   │   ├── app_text.dart
│   │   └── theme.dart               # Barrel file
│   ├── types/                       # Domain-safe types (no network dependency)
│   │   ├── result.dart              # Domain Result<T> with Failure
│   │   ├── failure.dart             # Failure hierarchy
│   │   └── types.dart               # Barrel file
│   └── utils/                       # Utility functions
│       ├── app_loader.dart
│       ├── app_snack_bar.dart
│       ├── color_print.dart
│       ├── image_sheet.dart
│       ├── shimmer_utils.dart
│       ├── stretch_scroll_behavior.dart
│       ├── ui_utils.dart
│       ├── utils.dart
│       └── formatters/
│           ├── number_input_formatter.dart
│           ├── upper_text_formatter.dart
│           └── formatters.dart      # Barrel file
│
├── routes/                          # App routing
│   ├── routes_name.dart             # Route name constants
│   └── routes.dart                  # Route definitions (GetPage list)
│
├── shared/                          # Shared across all features
│   ├── models/                      # Shared data models
│   │   ├── drop_down_model.dart
│   │   └── models.dart              # Barrel file
│   ├── widgets/                     # Reusable UI widgets
│   │   ├── app_app_bar.dart
│   │   ├── app_button.dart
│   │   ├── app_drop_down.dart
│   │   ├── app_icon_button.dart
│   │   ├── app_image_view.dart
│   │   ├── app_pin_code_field.dart
│   │   ├── app_text_field.dart
│   │   ├── app_animated_cliprect.dart
│   │   ├── bottom_border_container.dart
│   │   ├── screen_header.dart
│   │   ├── country_code_picker/
│   │   └── widgets.dart             # Barrel file
│   └── packages/                    # Custom packages (self-contained)
│       ├── animated_counter/
│       ├── country_code/
│       ├── country_state_city/
│       ├── marquee_widget/
│       ├── shake_widget/
│       └── text_input_formatters/
│
└── features/                        # Feature modules
    └── auth/
        ├── domain/                  # Pure business logic
        │   ├── user.dart            # Entity (pure Dart class)
        │   ├── auth_repository.dart # Repository interface (abstract)
        │   └── domain.dart          # Barrel file
        ├── data/                    # Implementation
        │   ├── user_model.dart      # DTO (fromJson, toJson, toEntity)
        │   ├── auth_remote_datasource.dart  # API calls
        │   ├── auth_repository_impl.dart    # Repository impl (handles Result)
        │   └── data.dart            # Barrel file
        └── presentation/           # UI + State
            ├── sign_in/
            │   ├── sign_in_view.dart
            │   ├── sign_in_controller.dart
            │   └── sign_in_bindings.dart
            ├── sign_up/
            │   ├── sign_up_view.dart
            │   ├── sign_up_controller.dart
            │   └── sign_up_bindings.dart
            ├── splash/
            │   ├── splash_view.dart
            │   ├── splash_controller.dart
            │   └── splash_bindings.dart
            └── shared/
                └── otp_dialog.dart  # Shared widgets within this feature
```

### What each top-level folder is for:

| Folder | Purpose | Shared or feature-specific? |
|---|---|---|
| `core/` | Infrastructure that any feature can use (network, theme, utils, constants) | Shared |
| `routes/` | Route names and page definitions | Shared |
| `shared/` | Reusable widgets, shared models, custom packages | Shared |
| `features/` | Feature modules, each with domain/data/presentation | Feature-specific |

---

## 2.1 Environment & .env Setup

**Goal:** All environment-specific values (base URLs, feature flags, endpoints) come from a single `.env` file, and the app always reads them after they are loaded.

- **Single `.env` file**
  - The repository commits `.env.example` as a template.
  - Each developer creates a local `.env` (ignored by git) from that template.
  - The same `.env` holds values for all environments; which set is used depends on `EnvironmentType`.

- **How `.env` is loaded**
  - `bootstrap.dart` is responsible for loading `.env` via `flutter_dotenv`:

    ```dart
    Future<void> bootstrap() async {
      WidgetsFlutterBinding.ensureInitialized();

      // Load .env first
      await dotenv.load(fileName: '.env');

      // Other bootstrap work (storage, Firebase, orientation, etc.)
    }
    ```

  - `main.dart` must call `await bootstrap()` **before** setting the environment:

    ```dart
    void main() async {
      // 1) Load .env and do bootstrap work
      await bootstrap();

      // 2) Now that dotenv is loaded, set the active environment
      AppEnvironment.setEnvironment(EnvironmentType.development);

      // 3) Start the app
      runApp(const MyApp());
    }
    ```

- **Environment selection**
  - Environment is chosen in `main.dart` via:

    ```dart
    AppEnvironment.setEnvironment(EnvironmentType.development);
    // or: .local, .staging, .production
    ```

  - `AppEnvironment.baseUrl` chooses one of:
    - `BASE_URL_LOCAL`
    - `BASE_URL_DEV`
    - `BASE_URL_STAGING`
    - `BASE_URL_PROD`
  - Additional flags are read from `.env`, for example:
    - `ENABLE_LOGGING`
    - `ENABLE_CRASHLYTICS`

- **ApiUrls and ClientService**
  - `ApiUrls` reads endpoint paths from `.env` (e.g. `EP_SIGN_IN`, `EP_SIGN_UP`, `EP_VALIDATE_SIGN_IN_OTP`, etc.).
  - `ClientService` configures Dio with:

    ```dart
    baseUrl: '${AppEnvironment.baseUrl}/${version ?? ApiUrls.apiV1}',
    ```

  - This ensures every HTTP request uses the correct base URL for the active environment.

- **Makefile helper**
  - There is a convenience target to create `.env` from the template:

    ```bash
    make env-setup
    ```

  - Behavior:
    - If `.env` does **not** exist: copy `.env.example` → `.env` and print a helpful message.
    - If `.env` already exists: print a notice and do nothing.

- **Git rules**
  - `.env` is **gitignored** and must never be committed.
  - `.env.example` **is** committed and should be kept in sync whenever new env keys are added.

**Summary rule:**  
Always create `.env` from `.env.example` (e.g. `make env-setup`), fill in the values, and never read `AppEnvironment`/`ApiUrls` before `bootstrap()` has completed.

---

## 3. Layer Rules and Dependencies

### Domain Layer (`features/<feature>/domain/`)

| Rule | Detail |
|---|---|
| **Contains** | Entities (pure Dart classes), repository interfaces (abstract classes) |
| **May import** | Only Dart SDK, `core/types/*`, same-feature domain files |
| **Must NOT import** | Flutter, GetX, Dio, `core/network/`, `core/theme/`, any data or presentation file |
| **Returns** | `Future<Entity>` directly (not `Future<Result<Entity>>`) |

### Data Layer (`features/<feature>/data/`)

| Rule | Detail |
|---|---|
| **Contains** | Models/DTOs (with `fromJson`, `toJson`, `toEntity`), remote datasources, repository implementations |
| **May import** | Domain (same feature), `core/*` (including network), same-feature data files |
| **Must NOT import** | Presentation layer, other features' data |
| **Responsibility** | Handles `Result` internally using `result.fold`. Returns entity or throws exception |

### Presentation Layer (`features/<feature>/presentation/`)

| Rule | Detail |
|---|---|
| **Contains** | Views (UI widgets), controllers (state), bindings (DI) |
| **May import** | Domain (repository interface, entities), `core/*`, `shared/*`, GetX, Flutter |
| **Must NOT import** | Data layer directly (exception: bindings import data layer for DI wiring) |
| **Responsibility** | Controller uses `try/catch` to handle entity or exception. Does NOT handle `Result` |

### Summary table:

| Layer | May Import | Must NOT Import |
|---|---|---|
| **Domain** | Dart SDK, `core/types/*` | Flutter, GetX, Dio, network, data, presentation |
| **Data** | Domain, `core/*` | Other features' data, presentation |
| **Presentation** | Domain, `core/*`, `shared/*`, GetX, Flutter | Data layer (except bindings for DI) |

---

## 4. Naming Conventions

### Folders

| Type | Pattern | Example |
|---|---|---|
| Feature | `features/{feature_name}/` | `features/auth/`, `features/products/` |
| Domain | `features/{feature}/domain/` | `features/auth/domain/` |
| Data | `features/{feature}/data/` | `features/auth/data/` |
| Presentation | `features/{feature}/presentation/` | `features/auth/presentation/` |
| Screen | `presentation/{screen_name}/` | `presentation/sign_in/` |

### Files

| Type | Pattern | Example | Location |
|---|---|---|---|
| Entity | `{name}.dart` | `user.dart`, `product.dart` | `domain/` |
| Repository interface | `{feature}_repository.dart` | `auth_repository.dart` | `domain/` |
| Model/DTO | `{name}_model.dart` | `user_model.dart` | `data/` |
| Remote datasource | `{feature}_remote_datasource.dart` | `auth_remote_datasource.dart` | `data/` |
| Repository impl | `{feature}_repository_impl.dart` | `auth_repository_impl.dart` | `data/` |
| View | `{screen}_view.dart` | `sign_in_view.dart` | `presentation/{screen}/` |
| Controller | `{screen}_controller.dart` | `sign_in_controller.dart` | `presentation/{screen}/` |
| Bindings | `{screen}_bindings.dart` | `sign_in_bindings.dart` | `presentation/{screen}/` |
| Barrel file | `{folder_name}.dart` | `constants.dart`, `domain.dart` | Same folder |

### Classes

| Type | Pattern | Example |
|---|---|---|
| Entity | PascalCase, no suffix | `User`, `Product`, `Order` |
| Repository interface | `{Feature}Repository` (abstract) | `AuthRepository`, `ProductRepository` |
| Repository impl | `{Feature}RepositoryImpl` | `AuthRepositoryImpl` |
| Model/DTO | `{Name}Model` | `UserModel`, `ProductModel` |
| Controller | `{Screen}Controller` | `SignInController`, `ProductListController` |
| Bindings | `{Screen}Bindings` | `SignInBindings` |
| Datasource | `{Feature}RemoteDataSource` | `AuthRemoteDataSource` |

### Functions

| Type | Pattern | Example |
|---|---|---|
| Repository methods | camelCase | `signIn()`, `getProducts()`, `updateProfile()` |
| Controller actions | `on` + Action | `onSignIn()`, `onVerify()`, `onResend()` |
| Model conversion | `fromJson`, `toJson`, `toEntity` | `UserModel.fromJson(json)`, `model.toEntity()` |
| Validators | `{field}Validator` | `emailValidator()`, `phoneValidator()` |

### Variables

| Type | Pattern | Example |
|---|---|---|
| Observable (Rx) | camelCase | `isLoading.obs`, `statusMessage.obs` |
| TextEditingController | `{field}Controller` | `phoneNumberController`, `otpController` |
| Form key | `{screen}FormKey` | `signInFormKey`, `signUpFormKey` |
| Private dependency | `_repository`, `_remoteDataSource` | `final AuthRepository _repository;` |

---

## 5. Data Flow (How a Feature Works)

Here is the complete flow when a user taps "Sign In":

```
User taps "Sign In" button
        │
        ▼
[View] ── calls ──> controller.onSignIn()
        │
        ▼
[Controller] ── calls ──> _repository.signIn(mobileNumber: ...)
        │                   (repository is injected via constructor)
        ▼
[Repository Impl] ── calls ──> _remoteDataSource.signIn(mobileNumber: ...)
        │
        ▼
[DataSource] ── calls ──> clientService.request(POST, "/auth/signin", data)
        │                  uses Dio under the hood
        ▼
[DataSource] ── receives ──> Result<BaseResponse, String> from ClientService
        │                     handles .when() - returns JSON or throws
        ▼
[Repository Impl] ── receives ──> JSON map
        │   1. Creates UserModel.fromJson(json)
        │   2. Creates Result<User> using Success(userModel.toEntity())
        │   3. Calls result.fold() internally
        │   4. Returns User entity (or throws Exception on failure)
        ▼
[Controller] ── receives ──> User entity (or catches Exception)
        │   try { final user = await _repository.signIn(...); }
        │   catch (e) { AppSnackBar.error(message: e.toString()); }
        ▼
[View] ── updates ──> UI reacts to controller's Rx variables
```

**Key point:** The controller NEVER sees `Result`, `Failure`, `BaseResponse`, or JSON. It only receives a domain entity or catches an exception.

---

## 6. Code Examples (Auth Feature)

### 6.1 Domain Entity (`features/auth/domain/user.dart`)

```dart
/// Pure business object — no JSON, no Flutter, no imports from data layer
class User {
  final String? id;
  final String? name;
  final String? mobileNumber;
  final String? address;
  final String? token;

  const User({this.id, this.name, this.mobileNumber, this.address, this.token});
}
```

### 6.2 Repository Interface (`features/auth/domain/auth_repository.dart`)

```dart
import 'user.dart';

/// Returns entity directly — Result handling is internal to the implementation
abstract class AuthRepository {
  Future<User> signIn({required String mobileNumber});
  Future<User> signUp({required String name, required String mobileNumber, required String address});
  Future<User> validateSignInOtp({required String mobileNumber, required String otp});
  Future<User> validateSignUpOtp({required String mobileNumber, required String otp});
  Future<void> resendOtp({required String mobileNumber});
}
```

### 6.3 Model/DTO (`features/auth/data/user_model.dart`)

```dart
import '../domain/user.dart';

class UserModel {
  final String? id;
  final String? name;
  final String? mobileNumber;
  final String? token;

  const UserModel({this.id, this.name, this.mobileNumber, this.token});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      mobileNumber: json['mobileNumber'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'mobileNumber': mobileNumber, 'token': token};

  /// Convert DTO to domain entity
  User toEntity() => User(id: id, name: name, mobileNumber: mobileNumber, token: token);
}
```

### 6.4 Remote Datasource (`features/auth/data/auth_remote_datasource.dart`)

```dart
import 'package:app_structure/core/config/api_url.dart';
import 'package:app_structure/core/network/client_service.dart';
import 'package:app_structure/features/auth/data/user_model.dart';
import 'package:app_structure/features/auth/domain/user.dart';

/// Remote datasource - Handles API calls
/// Extends ClientService so it can call `request` directly.
class AuthRemoteDataSource extends ClientService {
  Future<User> signIn({required String mobileNumber}) async {
    final response = await request(
      requestType: RequestType.post,
      path: ApiUrls.signIn,
      data: {'mobileNumber': mobileNumber},
    );

    return response.when(
      (success) {
        if (success.data != null) {
          return UserModel.fromJson(success.data).toEntity();
        }
        throw Exception(success.message);
      },
      (error) => throw Exception(error),
    );
  }
}
```

### 6.5 Repository Implementation (`features/auth/data/auth_repository_impl.dart`)

```dart
import 'package:app_structure/features/auth/data/auth_remote_datasource.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';
import 'package:app_structure/features/auth/domain/user.dart';

/// Repository implementation - Implements domain interface
/// Handles mapping errors to exceptions and returns entities directly.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<User> signIn({required String mobileNumber}) async {
    try {
      final user = await _remoteDataSource.signIn(mobileNumber: mobileNumber);
      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
```

### 6.6 Controller (`features/auth/presentation/sign_in/sign_in_controller.dart`)

```dart
import 'package:app_structure/core/storage/preferences.dart';
import 'package:app_structure/core/utils/app_snack_bar.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';
import 'package:app_structure/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  final AuthRepository _repository; // Injected, not created

  SignInController(this._repository);

  GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool isResendLoading = false.obs;

  /// Returns true if sign-in succeeded and the OTP dialog should be shown.
  Future<bool> onSignIn() async {
    if (signInFormKey.currentState?.validate() ?? false) {
      FocusManager.instance.primaryFocus?.unfocus();

      isLoading.value = true;

      try {
        await _repository.signIn(
          mobileNumber: phoneNumberController.text.trim(),
        );

        isLoading.value = false;
        return true;
      } catch (e) {
        isLoading.value = false;
        AppSnackBar.error(message: e.toString());
        return false;
      }
    }
    return false;
  }

  Future<void> onVerify() async {
    isLoading.value = true;

    try {
      final user = await _repository.validateSignInOtp(
        mobileNumber: phoneNumberController.text.trim(),
        otp: otpController.text.trim(),
      );

      isLoading.value = false;
      Get.back();
      // Handle successful login
      Preferences.user = user;
      Preferences.isLogged = true;
      Preferences.token = user.token;
      Get.offAllNamed(RoutesName.signInView);
    } catch (e) {
      isLoading.value = false;
      AppSnackBar.error(message: e.toString());
    }
  }

  Future<void> onResend() async {
    isResendLoading.value = true;

    try {
      await _repository.resendOtp(
        mobileNumber: phoneNumberController.text.trim(),
      );

      isResendLoading.value = false;
      AppSnackBar.success(message: 'OTP sent successfully');
    } catch (e) {
      isResendLoading.value = false;
      AppSnackBar.error(message: e.toString());
    }
  }

  @override
  void onClose() {
    phoneNumberController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
```

### 6.7 Bindings (`features/auth/presentation/sign_in/sign_in_bindings.dart`)

```dart
import 'package:app_structure/features/auth/data/auth_remote_datasource.dart';
import 'package:app_structure/features/auth/data/auth_repository_impl.dart';
import 'package:app_structure/features/auth/domain/auth_repository.dart';
import 'package:get/get.dart';
import 'sign_in_controller.dart';

class SignInBindings implements Bindings {
  @override
  void dependencies() {
    // 1. Data Source
    Get.lazyPut(() => AuthRemoteDataSource());

    // 2. Repository (inject data source)
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find()));

    // 3. Controller (inject repository)
    Get.lazyPut(() => SignInController(Get.find()));
  }
}
```

### 6.8 View (`features/auth/presentation/sign_in/sign_in_view.dart`)

```dart
import 'package:app_structure/core/theme/app_style.dart';
import 'package:app_structure/core/theme/app_text.dart';
import 'package:app_structure/core/mixins/validation_mixin.dart';
import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/constants/app_strings.dart';
import 'package:app_structure/features/auth/presentation/shared/otp_dialog.dart';
import 'package:app_structure/features/auth/presentation/sign_in/sign_in_controller.dart';
import 'package:app_structure/routes/routes_name.dart';
import 'package:app_structure/shared/widgets/app_app_bar.dart';
import 'package:app_structure/shared/widgets/app_button.dart';
import 'package:app_structure/shared/widgets/app_text_field.dart';
import 'package:app_structure/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignInView extends GetView<SignInController> with ValidationMixin {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(showBack: false),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(defaultPadding).copyWith(top: 0),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        clipBehavior: Clip.antiAlias,
        child: Form(
          key: controller.signInFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Screen Header
              const ScreenHeader(
                title: AppStrings.signIn,
                subtitle: AppStrings.pleaseEnterYourCredentialsToProceed,
              ),

              // Phone Text filed view
              AppTextField(
                controller: controller.phoneNumberController,
                label: AppStrings.phoneNumber,
                hintText: AppStrings.enterYourPhoneNumber,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  return phoneValidator(value, 10);
                },
              ),

              36.verticalSpace,

              // Sign in Button view
              Obx(
                () => AppButton(
                  onPressed: () async {
                    final shouldShowOtp = await controller.onSignIn();
                    if (context.mounted && shouldShowOtp) {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => OtpDialog(
                          otpController: controller.otpController,
                          isLoading: controller.isLoading,
                          isResendLoading: controller.isResendLoading,
                          onResend: controller.onResend,
                          onVerify: controller.onVerify,
                        ),
                      );
                    }
                  },
                  label: AppStrings.signIn,
                  isLoading: controller.isLoading.value,
                ),
              ),

              12.verticalSpace,

              // Did not have account view
              const AppText(
                AppStrings.doNotHaveAnAccount,
                textColor: AppColors.darkGreyTextColor,
                textSize: TextSize.small_12,
                textWeight: TextWeight.w600,
              ),

              12.verticalSpace,

              // Sign Up Text Button
              InkWell(
                onTap: () {
                  Get.toNamed(RoutesName.signUpView);
                },
                child: const AppText(
                  AppStrings.signUp,
                  textColor: AppColors.primaryColor,
                  textSize: TextSize.small_12,
                  textWeight: TextWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 7. Result and Error Handling

This project has **two** Result types for different layers:

### Network Result (`core/network/result.dart`)

Used by `ClientService` for HTTP responses. Two type parameters: `Result<Success, Failure>`.

```dart
// Used inside datasources to handle API responses:
final response = await _clientService.request(...);
response.when(
  (success) => success.data,       // BaseResponse
  (error) => throw Exception(error), // String error
);
```

### Domain Result (`core/types/result.dart`)

Used by repository implementations to handle business logic. One type parameter: `Result<T>` with built-in `Failure`.

```dart
abstract class Result<T> {
  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess);
}

class Success<T> extends Result<T> { ... }
class Error<T> extends Result<T> { ... }
```

### Failure hierarchy (`core/types/failure.dart`)

```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure { ... }
class CacheFailure extends Failure { ... }
```

### Where Result is handled:

| Layer | Handles | Pattern |
|---|---|---|
| **DataSource** | Network `Result<BaseResponse, String>` | `.when()` — returns JSON or throws |
| **Repository Impl** | Domain `Result<T>` | `.fold()` — returns entity or throws |
| **Controller** | Nothing | `try/catch` — receives entity or exception |

---

## 8. Dependency Injection

### Global services (registered once in `app.dart`):

```dart
class LazyBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ApiClient>(ApiClient(), permanent: true);
    Get.put(BaseViewController(), permanent: true);
    Get.put(DeepLinkManager(), permanent: true);
  }
}
```

### Per-screen bindings (registered when route is opened):

```dart
// Injection order: DataSource → Repository → Controller
Get.lazyPut(() => AuthRemoteDataSource(Get.find<ApiClient>()));
Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find()));
Get.lazyPut(() => SignInController(Get.find()));
```

**Rules:**
- Always register repository as its **interface type**: `Get.lazyPut<AuthRepository>(...)`
- Controller receives the **interface**, not the implementation
- Use `Get.lazyPut` (not `Get.put`) in screen bindings for lazy initialization
- Use `Get.put` with `permanent: true` for global services

---

## 9. Barrel (Export) Files

Barrel files re-export all files in a folder so consumers import one file instead of many.

**Convention:** Name the barrel file after the folder: `constants/constants.dart`, `theme/theme.dart`, etc.

**Example usage:**

```dart
// Instead of:
import 'package:app_structure/core/constants/app_colors.dart';
import 'package:app_structure/core/constants/app_strings.dart';
import 'package:app_structure/core/constants/app_assets.dart';

// Use:
import 'package:app_structure/core/constants/constants.dart';
```

**Barrel files exist in:**
`core/constants/`, `core/theme/`, `core/types/`, `core/extensions/`, `core/enums/`, `core/mixins/`, `core/storage/`, `core/utils/formatters/`, `shared/widgets/`, `shared/models/`, `features/auth/domain/`, `features/auth/data/`

**Barrel files do NOT exist in (by design):**
`core/network/`, `core/config/`, `core/base/`, `core/services/`, `core/utils/`, `shared/packages/`, `routes/`, screen folders — these are imported individually because files are used independently.

---

## 10. Import Rules

### Order of imports:

```dart
// 1. Flutter/Dart SDK
import 'package:flutter/material.dart';

// 2. Third-party packages
import 'package:get/get.dart';

// 3. Core imports
import 'package:app_structure/core/constants/constants.dart';
import 'package:app_structure/core/theme/theme.dart';

// 4. Shared imports
import 'package:app_structure/shared/widgets/widgets.dart';

// 5. Feature imports (domain)
import 'package:app_structure/features/auth/domain/auth_repository.dart';

// 6. Relative imports (same feature)
import 'sign_in_controller.dart';
```

### Cross-feature rules:

- Features should NOT import other features' internals
- If two features share data, extract it to `shared/models/`
- If two features share a widget, extract it to `shared/widgets/`

---

## 11. Adding a New Feature (Step-by-Step)

Example: Adding a **products** feature.

### Step 1: Create domain layer

```
lib/features/products/domain/
├── product.dart              # Entity
├── product_repository.dart   # Interface (abstract class)
└── domain.dart               # Barrel file
```

`product.dart`:
```dart
class Product {
  final String id;
  final String name;
  final double price;
  const Product({required this.id, required this.name, required this.price});
}
```

`product_repository.dart`:
```dart
import 'product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProductById({required String id});
}
```

### Step 2: Create data layer

```
lib/features/products/data/
├── product_model.dart              # DTO
├── product_remote_datasource.dart  # API calls
├── product_repository_impl.dart    # Implementation
└── data.dart                       # Barrel file
```

### Step 3: Create presentation layer

```
lib/features/products/presentation/
├── product_list/
│   ├── product_list_view.dart
│   ├── product_list_controller.dart
│   └── product_list_bindings.dart
└── product_detail/
    ├── product_detail_view.dart
    ├── product_detail_controller.dart
    └── product_detail_bindings.dart
```

### Step 4: Add routes

In `routes/routes_name.dart`:
```dart
static String productListView = '/products';
static String productDetailView = '/product-detail';
```

In `routes/routes.dart`:
```dart
getPage(name: RoutesName.productListView, page: () => const ProductListView(), binding: ProductListBindings()),
```

### Step 5: Add API endpoints

In `core/config/api_url.dart`:
```dart
static String getProducts = "products";
static String getProductById = "products/";
```

---

## 12. Adding a New Screen to an Existing Feature

Example: Adding a **forgot password** screen to the auth feature.

1. Create `features/auth/presentation/forgot_password/`
2. Add 3 files:
   - `forgot_password_view.dart`
   - `forgot_password_controller.dart`
   - `forgot_password_bindings.dart`
3. Add methods to `AuthRepository` interface if needed
4. Implement methods in `AuthRepositoryImpl`
5. Add datasource methods in `AuthRemoteDataSource`
6. Add route in `routes_name.dart` and `routes.dart`
7. Add API endpoint in `api_url.dart`

---

## 13. Where to Put New Files (Quick Lookup)

| I need to add... | Put it in... |
|---|---|
| New entity (User, Product) | `features/{feature}/domain/{name}.dart` |
| New repository interface | `features/{feature}/domain/{feature}_repository.dart` |
| New model/DTO | `features/{feature}/data/{name}_model.dart` |
| New API datasource | `features/{feature}/data/{feature}_remote_datasource.dart` |
| New repository implementation | `features/{feature}/data/{feature}_repository_impl.dart` |
| New screen | `features/{feature}/presentation/{screen}/` (3 files) |
| New shared widget | `shared/widgets/{widget_name}.dart` + update barrel |
| New shared model | `shared/models/{model_name}.dart` + update barrel |
| New custom package | `shared/packages/{package_name}/` |
| New color constant | `core/constants/app_colors.dart` |
| New string constant | `core/constants/app_strings.dart` |
| New asset path | `core/constants/app_assets.dart` |
| New extension | `core/extensions/{name}_extension.dart` + update barrel |
| New mixin | `core/mixins/{name}_mixin.dart` + update barrel |
| New enum | `core/enums/common_enums.dart` (or new file + update barrel) |
| New API endpoint | `core/config/api_url.dart` |
| New route | `routes/routes_name.dart` + `routes/routes.dart` |
| New Failure type | `core/types/failure.dart` |
| New global service | `core/services/` + register in `app.dart` |
| New storage utility | `core/storage/` + update barrel |
| New formatter | `core/utils/formatters/` + update barrel |
| New general utility | `core/utils/{name}.dart` |

---

## 14. State Management (GetX)

### Reactive variables (Rx):

```dart
RxBool isLoading = false.obs;
RxString errorMessage = ''.obs;
RxList<Product> products = <Product>[].obs;
```

### Updating state:

```dart
isLoading.value = true;          // Single value
products.addAll(newProducts);    // List operations
```

### Observing in UI:

```dart
Obx(() => AppButton(isLoading: controller.isLoading.value))
```

### Controller lifecycle:

```dart
class SignInController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Called when controller is created
  }

  @override
  void onClose() {
    phoneNumberController.dispose();  // Always dispose controllers
    super.onClose();
  }
}
```

---

## 15. Mixins

Mixins provide reusable behavior that can be mixed into views or controllers.

**Location:** `core/mixins/`

**Current mixins:**
- `ValidationMixin` — form validators (email, phone, password, name, address)

**Usage in views:**
```dart
class SignInView extends GetView<SignInController> with ValidationMixin {
  // Now has access to: emailValidator, phoneValidator, passwordValidator, etc.
}
```

**Guidelines:**
- Group mixins by **concern**, not by feature (e.g., `ValidationMixin`, not `AuthValidationMixin`)
- Keep mixins **stateless** — no instance variables, only methods
- If a mixin grows too large (500+ lines), split by concern
- Don't use mixins for business logic — that belongs in the repository or controller

---

## 16. Best Practices

### Architecture:
- One structure for all features — no mixing patterns
- Domain layer stays pure — no Flutter, no GetX, no Dio
- Repository handles Result — controller uses try/catch
- Inject dependencies via constructor — never instantiate directly

### Code quality:
- Always dispose `TextEditingController`s in `onClose()`
- Use `const` constructors wherever possible
- Use `RxBool`, `RxString`, `RxList` for reactive state
- Use `Obx()` only around the smallest widget that needs to rebuild
- Use `Get.lazyPut` (not `Get.put`) in screen bindings

### File organization:
- One class per file (exceptions: small related enums or helper classes)
- Update barrel files when adding new files to a folder
- Keep imports organized: Flutter → packages → core → shared → features → relative

### Naming:
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Functions/variables: `camelCase`
- Constants: `camelCase` (Dart convention, not UPPER_CASE)

---

## 17. What NOT to Do

| Don't | Do instead |
|---|---|
| Import data layer in controller | Import domain repository interface |
| Handle `Result`/`Failure` in controller | Handle in repository impl, controller uses try/catch |
| Create repository directly in controller | Inject via constructor + binding |
| Put JSON methods in domain entity | Put in data model/DTO, use `toEntity()` |
| Import Flutter/GetX in domain layer | Keep domain pure Dart only |
| Create per-flow mixins | Create per-concern mixins (validation, formatting) |
| Import one feature from another feature | Extract shared code to `shared/` |
| Skip disposing TextEditingControllers | Always dispose in `onClose()` |
| Use `Get.put` in screen bindings | Use `Get.lazyPut` for lazy initialization |
| Put widgets in `core/` | Put in `shared/widgets/` |
| Put constants in `data/` | Put in `core/constants/` |
| Create barrel files for everything | Only for folders with 2+ related files that are imported together |
