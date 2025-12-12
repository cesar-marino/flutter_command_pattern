// Import all test files to run them together
import 'integration/integration_test.dart' as integration;
import 'src/commands/command_test.dart' as command;
import 'src/commands/command_with_params_test.dart' as command_with_params;
import 'src/core/command_base_test.dart' as command_base;
import 'src/core/command_context_test.dart' as command_context;
import 'src/core/command_state_test.dart' as command_state;
import 'src/extensions/command_base_extension_test.dart' as extensions;
import 'src/observers/command_observer_registry_test.dart' as observer_registry;
import 'src/observers/command_observer_test.dart' as observer;
import 'src/pipelines/command_pipeline_registry_test.dart' as pipeline_registry;

void main() {
  command_state.main();
  command_context.main();
  command_base.main();
  command.main();
  command_with_params.main();
  pipeline_registry.main();
  observer_registry.main();
  observer.main();
  extensions.main();
  integration.main();
}
