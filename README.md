<!-- # Flutter Command Pattern

A powerful and elegant command pattern implementation for Flutter with pipeline support, observers, and state management.

## Features

✨ **Type-safe Commands** - Execute async operations with built-in state management  
🔄 **Pipeline System** - Chain middleware for logging, analytics, caching, etc.  
👀 **Global Observers** - Monitor all command executions across your app  
🎯 **Context-aware** - React to loading, success, and failure states  
📦 **Zero dependencies** - Pure Flutter implementation  

## Installation

```yaml
dependencies:
  flutter_command_pattern: ^1.0.0
```

## Quick Start

### Basic Command

```dart
final loginCommand = Command(() async {
  await authService.login(email, password);
});

// Execute
await loginCommand.execute();

// Observe state
loginCommand.observe(
  context,
  onLoading: (ctx) => showLoader(ctx),
  onSuccess: (ctx) => navigateToHome(ctx),
  onFailure: (ctx, error) => showError(ctx, error),
);
```

### Command with Parameters

```dart
final fetchUserCommand = CommandWithParams<String>((userId) async {
  return await api.fetchUser(userId);
});

await fetchUserCommand.execute('user123');
```

### Global Pipeline

```dart
void main() {
  // Add logging pipeline
  CommandPipelineRegistry.addPipeline((context, next) async {
    print('Command started: ${context.command.runtimeType}');
    await next();
    print('Command finished: ${context.state.runtimeType}');
  });

  runApp(MyApp());
}
```

### Global Observer

```dart
CommandObserverRegistry.addObserver((context) {
  if (context.state is CommandFailure) {
    analytics.logError(context.command, context.state);
  }
});
```

## Advanced Usage

See the [example](example/lib/main.dart) for a complete implementation.

## License

MIT License - see [LICENSE](LICENSE) file for details. -->

# Flutter Command Pattern

[![pub package](https://img.shields.io/pub/v/flutter_command_pattern.svg)](https://pub.dev/packages/flutter_command_pattern)
[![Build Status](https://github.com/cesar-marino/flutter_command_pattern/workflows/Tests/badge.svg)](https://github.com/cesar-marino/flutter_command_pattern/actions)
[![codecov](https://codecov.io/gh/cesar-marino/flutter_command_pattern/branch/main/graph/badge.svg)](https://codecov.io/gh/cesar-marino/flutter_command_pattern)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight yet powerful **Command Pattern** implementation for Flutter, focused on **simplicity**, **explicit state**, and **zero external dependencies**.

Designed for applications using **MVVM** and **Clean Architecture**, without relying on streams, Rx, or reactive libraries.

---

## Features

✨ **Type-safe Commands** – Encapsulate async actions with explicit execution state
🔄 **Pipeline System** – Intercept command execution for logging, analytics, caching, etc.
👀 **Global Observers** – React to command lifecycle events across the app
🎯 **Explicit State** – Loading, success, and failure handled in a predictable way
📦 **Zero dependencies** – Pure Flutter implementation

---

## Why Flutter Command Pattern?

This package is built for developers who want:

* Clear and predictable async flows
* No dependency on streams, Rx, or reactive abstractions
* Simple commands that integrate naturally with MVVM and Clean Architecture
* Centralized interception via pipelines (without magic)
* UI code free from business logic

If you prefer **explicitness over abstraction**, this package is for you.

---

## Installation

```yaml
dependencies:
  flutter_command_pattern: ^1.0.0
```

---

## Quick Start (MVVM-oriented)

### ViewModel with Commands

In MVVM, commands usually live inside the ViewModel and represent **user intents** or **use cases**.

```dart
class LoginViewModel {
  final AuthService authService;

  late final Command loginCommand;

  LoginViewModel(this.authService) {
    loginCommand = Command(() async {
      await authService.login(email, password);
    });
  }

  String email = '';
  String password = '';
}
```

---

### Executing the Command from the UI

```dart
ElevatedButton(
  onPressed: () => viewModel.loginCommand.execute(),
  child: const Text('Login'),
);
```

---

### Observing Command State in the UI

```dart
@override
void initState() {
  super.initState();

  viewModel.loginCommand.observe(
    context,
    onLoading: (_) => showLoader(context),
    onSuccess: (_) => navigateToHome(context),
    onFailure: (_, error) => showError(context, error),
  );
}
```

This keeps **widgets dumb** and moves all business logic into the ViewModel.

---

## Command with Parameters (Use Case style)

Commands can also represent parameterized use cases:

```dart
class FetchUserViewModel {
  final UserApi api;

  late final User user;

  late final CommandWithParams<String> fetchUserCommand;

  FetchUserViewModel(this.api) {
    fetchUserCommand = CommandWithParams((userId) async {
      user = api.fetchUser(userId);
    });
  }
}
```

```dart
viewModel.fetchUserCommand.execute('user-123');
```

---

## Global Pipelines

Pipelines allow cross-cutting concerns without polluting ViewModels.

```dart
void main() {
  CommandPipelineRegistry.addPipeline((context, next) async {
    debugPrint('Command started: ${context.command.runtimeType}');
    await next();
    debugPrint('Command finished with state: ${context.state.runtimeType}');
  });

  runApp(const MyApp());
}
```

Common use cases:

* Logging
* Performance monitoring
* Analytics
* Authorization checks

---

## Global Observers

Observers react to command lifecycle events globally.

```dart
CommandObserverRegistry.addObserver((context) {
  if (context.state is CommandFailure) {
    analytics.logError(
      command: context.command,
      error: (context.state as CommandFailure).error,
    );
  }
});
```

---

## Quality

* ✅ Pub.dev score: **160 / 160**
* ✅ Fully null-safe
* ✅ Zero external dependencies
* ✅ High test coverage

---

## Example

See the [example](example/lib/main.dart) for a complete implementation.

---

## License

MIT License - see [LICENSE](LICENSE) file for details.