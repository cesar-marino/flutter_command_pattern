import '../core/command_base.dart';
import '../typedefs/command_typedefs.dart';

/// A command that executes an action without parameters.
///
/// Example:
/// ```dart
/// final loginCommand = Command(() async {
///   await authService.login(email, password);
/// });
///
/// await loginCommand.execute();
/// ```
class Command extends CommandBase {
  final CommandAction _action;

  /// Creates a command with the given action.
  Command(this._action);

  /// Executes the command.
  Future<void> execute() => executeBase(_action);
}
