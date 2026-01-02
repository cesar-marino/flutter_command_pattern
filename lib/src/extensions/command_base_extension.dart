import 'package:flutter/material.dart';
import '../core/command_base.dart';
import '../observers/command_observer.dart';
import '../typedefs/command_typedefs.dart';

/// Extension methods for [CommandBase].
extension CommandBaseExtension on CommandBase {
  /// Observes command state changes with context-aware callbacks.
  ///
  /// This implementation is lifecycle-safe:
  /// - Automatically removes the listener when the BuildContext is disposed
  /// - Prevents callbacks from running on a dead FlutterView (Web-safe)
  /// - Does NOT require manual dispose by the developer
  void observe(
    BuildContext context, {
    OnLoading? onLoading,
    OnSuccess? onSuccess,
    OnFailure? onFailure,
  }) {
    final observer = CommandObserver(
      context: context,
      onLoading: onLoading,
      onSuccess: onSuccess,
      onFailure: onFailure,
    );

    late VoidCallback listener;

    listener = () {
      if (!context.mounted) {
        removeListener(listener);
        return;
      }

      observer.observe(state);
    };

    addListener(listener);
  }
}
