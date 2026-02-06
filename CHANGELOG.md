## 1.1.1
* Fix: Update CommandFailure structure to properly handle CommandError
* Fix: Update all test assertions to validate CommandError properties
* Fix: Update CommandObserver callbacks to properly handle CommandError type
* Fix: Update OnFailure typedef to receive CommandError instead of Object
* Ensure all exceptions are properly mapped to CommandError before state emission

## 1.1.0
* Add custom error mapping system with `CommandError` class
* Introduce `CommandErrorMapperRegistry` for registering custom error mappers
* All exceptions are now automatically wrapped in standardized `CommandError` objects
* Support mapping custom exception types to semantic error codes and messages
* Add automatic fallback for unmapped exceptions (code: null, message: error.toString())
* Breaking change: `CommandBase.error` now returns `CommandError?` instead of `Object?`
* Add comprehensive error mapping documentation and examples
* Fully backward compatible via automatic error wrapping

## 1.0.6
* Fix README link

## 1.0.5
* Fix README link

## 1.0.4
* Fix: Make `Command.observe` lifecycle-safe
* Automatically removes listeners when `BuildContext` is disposed
* Prevents callbacks from running after widget disposal (Flutter Web safe)
* Eliminates crashes caused by rendering disposed EngineFlutterView
* No manual dispose required by the developer

## 1.0.3
* Update README to include full examples

## 1.0.2
* Update README to include full examples

## 1.0.1
* Add flag `isCompleted` in CommandBase

## 1.0.0
* Initial release
* Command pattern implementation with state management
* Support for commands with and without parameters
* Global pipeline system for middleware
* Global observer system for monitoring
* Context-aware state handling
* Comprehensive documentation and examples
