import '../typedefs/command_typedefs.dart';

/// Registry for global command pipelines.
///
/// Pipelines are middleware that can intercept command execution
/// to add cross-cutting concerns like logging, analytics, caching, etc.
///
/// Example:
/// ```dart
/// CommandPipelineRegistry.addPipeline((context, next) async {
///   print('Command started: ${context.command.runtimeType}');
///   final stopwatch = Stopwatch()..start();
///
///   await next();
///
///   stopwatch.stop();
///   print('Command finished in ${stopwatch.elapsedMilliseconds}ms');
/// });
/// ```
class CommandPipelineRegistry {
  static final List<CommandPipeline> _globalPipelines = [];

  /// Adds a pipeline to the global registry.
  ///
  /// Pipelines are executed in the order they are added.
  /// Each pipeline must call [next] to continue the chain.
  static void addPipeline(CommandPipeline pipeline) {
    _globalPipelines.add(pipeline);
  }

  /// Returns an unmodifiable list of all registered pipelines.
  static List<CommandPipeline> get pipelines =>
      List.unmodifiable(_globalPipelines);

  /// Removes a specific pipeline from the registry.
  static bool removePipeline(CommandPipeline pipeline) {
    return _globalPipelines.remove(pipeline);
  }

  /// Clears all registered pipelines.
  ///
  /// Useful for testing or resetting the application state.
  static void clear() {
    _globalPipelines.clear();
  }
}
