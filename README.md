# Flutter Command Pattern

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

MIT License - see [LICENSE](LICENSE) file for details.