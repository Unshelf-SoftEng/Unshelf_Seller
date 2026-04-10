# Coding Standards -- Unshelf Seller

## Dart / Flutter

### Naming

- Classes: `PascalCase` (`OrderViewModel`, `BatchService`)
- Files: `snake_case` (`order_viewmodel.dart`, `batch_service.dart`)
- Variables, methods: `camelCase` (`fetchOrders`, `isLoading`)
- Constants: `camelCase` (`transactionFeePercent`, not `TRANSACTION_FEE_PERCENT`)
- Interfaces: prefix with `I` (`IOrderService`, `IBatchService`)
- Private members: prefix with `_` (`_isLoading`, `_orders`)

### Types

- Always declare explicit types on public APIs and class fields
- Use `final` for fields that don't change after construction
- Never use `dynamic` unless absolutely necessary -- use proper types or generics
- Prefer `num?` with null-safe cast over `?? 0 as num` patterns:
  ```dart
  // Good
  (data['price'] as num?)?.toDouble() ?? 0.0

  // Bad
  (data['price'] ?? 0 as num).toDouble()
  ```

### Null Safety

- Avoid force-unwrapping (`!`) on Firebase data -- always provide fallbacks
- Use `CurrentUserProvider.uid` instead of `FirebaseAuth.instance.currentUser!.uid`
- Check `mounted` before using `BuildContext` after async gaps:
  ```dart
  await someAsyncWork();
  if (!mounted) return;
  Navigator.of(context).pop();
  ```

## Architecture

### MVVM Layers

```
Views (UI only) --> ViewModels (state + logic) --> Services (data access) --> Firebase
```

- **Views**: Display data, delegate user actions to viewmodels. No business logic. No direct Firebase calls.
- **ViewModels**: Extend `BaseViewModel`. Manage state, call services. No `FirebaseFirestore.instance` calls. No widget references.
- **Services**: Implement interfaces from `core/interfaces/`. Own all Firebase/external access. No UI awareness. No `ChangeNotifier`.
- **Models**: Data classes with `fromDocument()` / `toMap()`. Immutable where possible (`final` fields).

### Dependency Injection

- All services registered in `core/service_locator.dart` via `get_it`
- ViewModels receive services through constructor injection:
  ```dart
  class OrderViewModel extends BaseViewModel {
    final IOrderService _orderService;
    OrderViewModel({required IOrderService orderService})
        : _orderService = orderService;
  }
  ```
- Never instantiate services directly in viewmodels (`OrderService()` is forbidden)

### BaseViewModel

- All viewmodels extend `BaseViewModel`
- Use `runBusyFuture()` for async operations -- handles loading state and error capture automatically
- Never manually toggle `_isLoading` / call `notifyListeners()` for loading patterns
- Access errors via `errorMessage` getter, clear with `clearError()`

### Error Handling

- Services throw typed exceptions: `AuthException`, `FirestoreException`, `ValidationException`
- ViewModels catch errors via `runBusyFuture()` -- they surface to `errorMessage`
- Views display `errorMessage` from viewmodel when non-null
- Never catch-and-ignore. If you catch, log with `AppLogger.error()` and either rethrow or surface to user.

## Code Organization

### Imports

- Use absolute package imports: `package:unshelf_seller/core/...`
- Never use relative imports (`../`, `./`)
- Group imports: dart, flutter, packages, project (separated by blank lines)
  ```dart
  import 'dart:async';

  import 'package:flutter/material.dart';

  import 'package:provider/provider.dart';

  import 'package:unshelf_seller/core/base_viewmodel.dart';
  import 'package:unshelf_seller/models/order_model.dart';
  ```

### Constants

- Firestore collection/field names: `FirestoreConstants.orders`, `FirestoreConstants.sellerId`
- Order statuses: `StatusConstants.pending`, `StatusConstants.completed`
- App config (durations, fees): `AppConstants.transactionFeePercent`
- Never hardcode collection names, status strings, or magic numbers inline

### Logging

- Use `AppLogger` for all logging: `.info()`, `.debug()`, `.warning()`, `.error()`
- Never use `print()` in production code
- Error logs include the error object: `AppLogger.error('Failed to fetch', e, stackTrace)`

## Views / UI

### Widget Structure

- Keep views under 300 lines. Extract sub-widgets when a view grows beyond this.
- Extract repeated patterns into reusable components in `lib/components/`
- Use `const` constructors wherever possible
- Widgets that don't depend on viewmodel state should be outside `Consumer` scope

### State Management in Views

- Use `Consumer<T>` or `context.watch<T>()` for reactive rebuilds
- Use `context.read<T>()` for one-shot access (e.g., in `onPressed`)
- Never duplicate viewmodel state into local `State` variables
- Scope `Consumer` to the smallest widget subtree that needs it

### Navigation

- Use `Navigator.push` with `MaterialPageRoute` consistently
- Pass data via constructor parameters, not viewmodel side-channels
- Check `mounted` before navigation after async operations

### Forms

- Validate in viewmodel, not in view (beyond basic `TextFormField` validators)
- Always dispose `TextEditingController` instances in `dispose()`

## Testing

### Structure

- Test files mirror source structure: `lib/services/order_service.dart` -> `test/services/order_service_test.dart`
- Use `mockito` with `@GenerateMocks` for service interfaces
- Group related tests with `group()`
- Test names describe behavior: `'fetchOrders sets loading state correctly'`

### What to Test

- **Services**: Verify Firestore calls are made with correct parameters
- **ViewModels**: Verify state transitions (loading, error, data), verify delegation to services
- **Models**: Verify `fromDocument()` / `toMap()` round-trips, verify null/missing field handling

### Test Pattern

```dart
test('descriptive behavior name', () async {
  // Arrange
  when(mockService.method()).thenAnswer((_) async => expectedData);

  // Act
  await viewModel.fetchData();

  // Assert
  expect(viewModel.isLoading, false);
  expect(viewModel.data, expectedData);
  verify(mockService.method()).called(1);
});
```

## Git

- Atomic commits: one logical change per commit
- Commit message format: `type: description` (e.g., `fix:`, `feat:`, `refactor:`, `test:`, `chore:`, `docs:`)
- No `Co-Authored-By` tags
- Feature branches: `feature/phase-N-description`
- Run `flutter analyze` before every commit -- zero errors allowed
