/// Custom error class for the command pattern plugin.
///
/// Represents a standardized error structure with code, message, and stack trace.
/// All fields are nullable to accommodate different error scenarios.
class CommandError {
  /// Error code for categorization and handling.
  /// Can be null if the error doesn't have a code.
  final String? code;

  /// Human-readable error message.
  /// Can be null if the error doesn't have a message.
  final String? message;

  /// Initial error object or stack trace.
  /// Can be null if not provided.
  final Object? initialError;

  /// Creates a new [CommandError].
  ///
  /// All parameters are optional and can be null.
  /// Example:
  /// ```dart
  /// final error = CommandError(
  ///   code: 'NETWORK_ERROR',
  ///   message: 'Failed to fetch data',
  ///   initialError: originalException,
  /// );
  /// ```
  const CommandError({
    this.code,
    this.message,
    this.initialError,
  });

  @override
  String toString() {
    final parts = <String>[];
    if (code != null) parts.add('code: $code');
    if (message != null) parts.add('message: $message');
    if (initialError != null) parts.add('initialError: $initialError');
    return 'CommandError(${parts.join(', ')})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandError &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          initialError == other.initialError;

  @override
  int get hashCode => Object.hash(code, message, initialError);
}
