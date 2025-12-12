/// A powerful command pattern implementation for Flutter.
///
/// This library provides:
/// - Type-safe command execution with state management
/// - Pipeline system for middleware
/// - Global observers for monitoring
/// - Context-aware state handling
library flutter_command_pattern;

export 'src/commands/command.dart';
export 'src/commands/command_with_params.dart';
export 'src/core/command_base.dart';
export 'src/core/command_context.dart';
export 'src/core/command_state.dart';
export 'src/extensions/command_base_extension.dart';
export 'src/observers/command_observer.dart';
export 'src/observers/command_observer_registry.dart';
export 'src/pipelines/command_pipeline.dart';
export 'src/pipelines/command_pipeline_registry.dart';
export 'src/typedefs/command_typedefs.dart';
