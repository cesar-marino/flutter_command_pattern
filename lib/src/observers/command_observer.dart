import 'package:flutter/material.dart';
import '../core/command_state.dart';
import '../typedefs/command_typedefs.dart';

/// A context-aware observer for command state changes.
///
/// Provides callbacks for loading, success, and failure states.
/// Typically used with the [CommandBase.observe] extension method.
class CommandObserver {
  /// The build context for UI operations.
  final BuildContext context;

  /// Callback when command starts loading.
  final OnLoading? onLoading;

  /// Callback when command succeeds.
  final OnSuccess? onSuccess;

  /// Callback when command fails.
  final OnFailure? onFailure;

  /// Creates a command observer with optional callbacks.
  const CommandObserver({
    required this.context,
    this.onLoading,
    this.onSuccess,
    this.onFailure,
  });

  /// Observes a command state and triggers appropriate callbacks.
  void observe(CommandState state) {
    switch (state) {
      case CommandRunning():
        onLoading?.call(context);
        break;

      case CommandFailure(:final error):
        onFailure?.call(context, error);
        break;

      case CommandSuccess():
        onSuccess?.call(context);
        break;

      case CommandInitial():
        break;
    }
  }
}
