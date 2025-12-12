import 'package:flutter/material.dart';
import '../core/command_base.dart';
import '../observers/command_observer.dart';
import '../typedefs/command_typedefs.dart';

/// Extension methods for [CommandBase].
extension CommandBaseExtension on CommandBase {
  /// Observes command state changes with context-aware callbacks.
  ///
  /// Example:
  /// ```dart
  /// loginCommand.observe(
  ///   context,
  ///   onLoading: (ctx) {
  ///     showDialog(
  ///       context: ctx,
  ///       builder: (_) => LoadingDialog(),
  ///     );
  ///   },
  ///   onSuccess: (ctx) {
  ///     Navigator.of(ctx).pop(); // Close loading
  ///     Navigator.of(ctx).pushNamed('/home');
  ///   },
  ///   onFailure: (ctx, error) {
  ///     Navigator.of(ctx).pop(); // Close loading
  ///     ScaffoldMessenger.of(ctx).showSnackBar(
  ///       SnackBar(content: Text('Error: $error')),
  ///     );
  ///   },
  /// );
  /// ```
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

    addListener(() {
      observer.observe(state);
    });
  }
}
