import '../typedefs/command_typedefs.dart';

/// Registry for global command observers.
///
/// Observers are notified of all command state changes across the application.
/// Useful for cross-cutting concerns like analytics, error tracking, etc.
///
/// Example:
/// ```dart
/// CommandObserverRegistry.addObserver((context) {
///   if (context.state is CommandFailure) {
///     analytics.logError(
///       context.command.runtimeType.toString(),
///       context.error,
///     );
///   }
/// });
/// ```
class CommandObserverRegistry {
  static final List<CommandObserverFn> _globalObservers = [];

  /// Adds an observer to the global registry.
  ///
  /// The observer will be called for every command state change.
  static void addObserver(CommandObserverFn observer) {
    _globalObservers.add(observer);
  }

  /// Returns an unmodifiable list of all registered observers.
  static List<CommandObserverFn> get observers =>
      List.unmodifiable(_globalObservers);

  /// Removes a specific observer from the registry.
  static bool removeObserver(CommandObserverFn observer) {
    return _globalObservers.remove(observer);
  }

  /// Clears all registered observers.
  ///
  /// Useful for testing or resetting the application state.
  static void clear() {
    _globalObservers.clear();
  }
}
