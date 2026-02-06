import 'package:flutter/material.dart';
import '../core/command_context.dart';
import '../core/command_error.dart';

/// A function that executes a command action.
typedef CommandAction = Future<void> Function();

/// A function that executes a command action with a parameter.
typedef CommandActionWithParams<P> = Future<void> Function(P param);

/// A function to call the next pipeline in the chain.
typedef PipelineNext = Future<void> Function();

/// A pipeline function that can intercept command execution.
///
/// Pipelines receive the command context and a [next] function.
/// They must call [next] to continue the pipeline chain.
///
/// Example:
/// ```dart
/// CommandPipelineRegistry.addPipeline((context, next) async {
///   print('Before execution');
///   await next();
///   print('After execution');
/// });
/// ```
typedef CommandPipeline = Future<void> Function(
  CommandContext context,
  PipelineNext next,
);

/// A function that observes command state changes.
typedef CommandObserverFn = void Function(CommandContext context);

/// Callback for when a command starts loading.
typedef OnLoading = void Function(BuildContext context);

/// Callback for when a command succeeds.
typedef OnSuccess = void Function(BuildContext context);

/// Callback for when a command fails.
typedef OnFailure = void Function(BuildContext context, CommandError error);
