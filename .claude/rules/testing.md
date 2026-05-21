---
alwaysApply: true
---

# Testing

- Verify behavior, not implementation. Don't assert mock call counts when output values would do.
- Run the specific test file after changes, not the full suite. Faster feedback, fewer tokens.
- Flaky test? Fix it or delete it. Never retry to make it pass.
- Prefer real implementations. Mock only at system boundaries (network, filesystem, clock, randomness).
- One assertion per test. Test names describe behavior. Arrange-Act-Assert. No `if` or loops in tests.
- Never `expect(true)` or check a mock was called without verifying arguments.

## Mocking strategy (skeleton-specific)

- Mock the `domain/` Repository interface (e.g. `AuthRepository`) — never the impl, the datasource, or `ApiClient`. The impl is the unit under test in its own file; everything above the impl tests against the interface.
- Use `mocktail` (no codegen). Declare mocks as `class _MockAuthRepository extends Mock implements AuthRepository {}` in the test file.
- Reset GetX between tests via `Get.testMode = true` + `Get.reset()`. Use the shared helper in `test/_helpers/test_bootstrap.dart`.
- For controller tests: instantiate the controller directly (`LoginController(mockRepo)`) — don't go through `Bindings`. Assert on `state.value`, `errorMessage.value`, and the returned `bool`.
- For repo impl tests: mock `XRemoteDataSource` + `SecureStorageService` + `LocalStorageService`. Assert on the storage `verify` calls (saveToken, saveUserData, etc.) — those side effects ARE the behavior.
