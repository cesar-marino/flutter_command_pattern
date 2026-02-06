import 'package:flutter_command_pattern/src/core/command_error.dart';

/// Represents the state of a command execution.
///
/// A command can be in one of four states:
/// - [CommandInitial]: Not yet executed
/// - [CommandRunning]: Currently executing
/// - [CommandSuccess]: Completed successfully
/// - [CommandFailure]: Failed with an error
sealed class CommandState {
  const CommandState();
}

/// Initial state before command execution.
final class CommandInitial extends CommandState {
  const CommandInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CommandInitial;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State while command is executing.
final class CommandRunning extends CommandState {
  const CommandRunning();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CommandRunning;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State after successful execution.
final class CommandSuccess extends CommandState {
  const CommandSuccess();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CommandSuccess;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// State after failed execution.
final class CommandFailure extends CommandState {
  /// Standardized command error with code, message, and initial error.
  final CommandError error;

  /// The original error that caused the failure.
  final Object? originalError;

  /// Optional stack trace for debugging.
  final StackTrace? stackTrace;

  const CommandFailure(
    this.error, [
    this.originalError,
    this.stackTrace,
  ]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommandFailure &&
          other.error == error &&
          other.originalError == originalError &&
          other.stackTrace == stackTrace);

  @override
  int get hashCode => Object.hash(error, originalError, stackTrace);

  @override
  String toString() => 'CommandFailure(error: $error)';
}
