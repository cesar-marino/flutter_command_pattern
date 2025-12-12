import '../core/command_base.dart';
import '../typedefs/command_typedefs.dart';

/// A command that executes an action with a typed parameter.
///
/// Example:
/// ```dart
/// final fetchUserCommand = CommandWithParams<String>((userId) async {
///   return await api.fetchUser(userId);
/// });
///
/// await fetchUserCommand.execute('user123');
/// ```
class CommandWithParams<T> extends CommandBase {
  final CommandActionWithParams<T> _action;

  /// Creates a command with the given parameterized action.
  CommandWithParams(this._action);

  /// Executes the command with the given parameter.
  Future<void> execute(T param) => executeBase(() => _action(param));
}
