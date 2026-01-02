# ❤️ Support Flutter Command Pattern

If this plugin helps you create cleaner and more predictable Flutter applications, please consider **leaving a 👍 here and a ⭐ on GitHub** — it really helps with the growth and visibility of the project.

You can also support the development by buying me a coffee ☕👇

[![Buy Me a Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png)](https://www.buymeacoffee.com/cesarmarino)

---

# Flutter Command Pattern

[![pub package](https://img.shields.io/pub/v/flutter_command_pattern.svg)](https://pub.dev/packages/flutter_command_pattern)
[![Build Status](https://github.com/cesar-marino/flutter_command_pattern/workflows/Tests/badge.svg)](https://github.com/cesar-marino/flutter_command_pattern/actions)
[![codecov](https://codecov.io/gh/cesar-marino/flutter_command_pattern/branch/main/graph/badge.svg)](https://codecov.io/gh/cesar-marino/flutter_command_pattern)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight yet powerful **Command Pattern** implementation for Flutter, focused on **simplicity**, **explicit state**, and **zero external dependencies**.

Designed for applications using **MVVM** and **Clean Architecture**, without relying on streams, Rx, or reactive libraries.

---

## Features

- ✨ **Type-safe Commands** – Encapsulate async actions with explicit execution state
- 🔄 **Pipeline System** – Intercept command execution for logging, analytics, caching, etc.
- 👀 **Global & Lifecycle-safe Observers** – React to command lifecycle events across the app without memory leaks
- 🎯 **Explicit State** – Loading, success, and failure handled in a predictable way
- 📦 **Zero dependencies** – Pure Flutter implementation

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
  flutter_command_pattern: ^1.0.4
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

> ℹ️ `observe` is lifecycle-safe.  
> Listeners are automatically removed when the widget is disposed, so no manual cleanup is required — even on Flutter Web.

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