import 'package:flutter/foundation.dart';
import '../observers/command_observer_registry.dart';
import '../pipelines/command_pipeline_registry.dart';
import '../typedefs/command_typedefs.dart';
import 'command_context.dart';
import 'command_error.dart';
import 'command_error_mapper.dart';
import 'command_state.dart';

/// Base class for all commands.
///
/// Provides state management and execution lifecycle.
/// Extend this class to create custom command implementations.
abstract class CommandBase extends ChangeNotifier {
  CommandState _state = const CommandInitial();

  /// The current state of the command.
  CommandState get state => _state;

  /// Whether the command is currently running.
  bool get isRunning => _state is CommandRunning;

  /// Whether the command is completed.
  bool get isCompleted => _state is CommandSuccess;

  /// Whether the command has failed.
  bool get hasError => _state is CommandFailure;

  /// The error if the command failed, null otherwise.
  CommandError? get error {
    if (_state is CommandFailure) {
      final failure = _state as CommandFailure;
      return failure.commandError as CommandError?;
    }
    return null;
  }

  /// Executes the command with the given action.
  ///
  /// This method:
  /// 1. Prevents concurrent executions
  /// 2. Runs through all registered pipelines
  /// 3. Manages state transitions
  /// 4. Notifies observers
  @protected
  Future<void> executeBase(CommandAction action) async {
    if (_state is CommandRunning) return;

    final context = CommandContext(command: this, state: _state);

    Future<void> runAction() async {
      _emit(const CommandRunning(), context);

      try {
        await action();
        _emit(const CommandSuccess(), context);
      } catch (error, stackTrace) {
        final commandError =
            CommandErrorMapperRegistry.mapError(error, stackTrace);
        _emit(CommandFailure(error, stackTrace, commandError), context);
      }
    }

    // Build pipeline chain from registered pipelines
    final pipelineChain = CommandPipelineRegistry.pipelines.reversed.fold(
      runAction,
      (next, pipeline) => () => pipeline(context, next),
    );

    // Execute the complete pipeline chain
    await pipelineChain();
  }

  // Emits a new state and notifies observers.
  void _emit(CommandState newState, CommandContext context) {
    context.state = newState;
    _state = newState;
    // Notify global observers
    for (final observer in CommandObserverRegistry.observers) {
      //observer(context);
      try {
        observer(context);
      } catch (_) {
        // intentionally ignored
      }
    }

    notifyListeners();
  }

  /// Resets the command to its initial state.
  void reset() {
    _state = const CommandInitial();
    notifyListeners();
  }
}
