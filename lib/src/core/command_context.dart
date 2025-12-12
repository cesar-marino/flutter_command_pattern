import 'command_base.dart';
import 'command_state.dart';

/// Context information about a command execution.
///
/// Contains the command being executed and its current state.
/// Used by pipelines and observers to track command execution.
class CommandContext {
  /// The command being executed.
  final CommandBase command;

  /// The current state of the command.
  CommandState state;

  /// Creates a new command context.
  CommandContext({
    required this.command,
    required this.state,
  });

  /// Whether the command is currently running.
  bool get isRunning => state is CommandRunning;

  /// Whether the command has completed successfully.
  bool get isSuccess => state is CommandSuccess;

  /// Whether the command has failed.
  bool get hasError => state is CommandFailure;

  /// The error if the command failed, null otherwise.
  Object? get error =>
      state is CommandFailure ? (state as CommandFailure).error : null;

  @override
  String toString() =>
      'CommandContext(command: ${command.runtimeType}, state: ${state.runtimeType})';
}
