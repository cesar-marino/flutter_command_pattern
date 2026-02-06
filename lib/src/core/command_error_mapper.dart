import 'command_error.dart';

/// Registry for custom error mappers.
///
/// Allows users to define how their custom exceptions should be converted
/// to [CommandError] instances for standardized error handling.
///
/// Example:
/// ```dart
/// // Register a custom mapper for your exception type
/// CommandErrorMapperRegistry.register<MyCustomException>(
///   (exception) => CommandError(
///     code: 'CUSTOM_ERROR',
///     message: exception.message,
///     initialError: exception,
///   ),
/// );
///
/// // The mapper will be automatically used when that exception is caught
/// ```
class CommandErrorMapperRegistry {
  static final Map<Type, Function> _mappers = {};

  /// Registers a custom error mapper for a specific exception type.
  ///
  /// Parameters:
  ///   - [mapper]: A function that converts the exception to a [CommandError]
  ///
  /// Example:
  /// ```dart
  /// CommandErrorMapperRegistry.register<IOException>(
  ///   (exception) => CommandError(
  ///     code: 'IO_ERROR',
  ///     message: exception.toString(),
  ///     initialError: exception,
  ///   ),
  /// );
  /// ```
  static void register<T extends Object>(CommandErrorMapper<T> mapper) {
    _mappers[T] = mapper;
  }

  /// Checks if a mapper is registered for the given type.
  static bool hasMapper(Type type) {
    return _mappers.containsKey(type);
  }

  /// Attempts to map an exception to a [CommandError].
  ///
  /// If a mapper is registered for the exception's type, it will be used.
  /// Otherwise, creates a default [CommandError] with the exception as [initialError].
  static CommandError mapError(Object error, [StackTrace? stackTrace]) {
    final mapper = _mappers[error.runtimeType];

    if (mapper != null) {
      try {
        // Call the mapper function directly
        final result = Function.apply(mapper as Function, [error]);
        return result as CommandError;
      } catch (_) {
        // If mapper fails, fall back to default behavior
      }
    }

    // Default mapping
    return CommandError(
      message: error.toString(),
      initialError: error,
    );
  }

  /// Clears all registered mappers.
  ///
  /// Useful for testing purposes.
  static void clear() {
    _mappers.clear();
  }
}

/// Type definition for error mapper functions.
///
/// A mapper function takes an exception of type [T] and returns a [CommandError].
typedef CommandErrorMapper<T extends Object> = CommandError Function(T error);
