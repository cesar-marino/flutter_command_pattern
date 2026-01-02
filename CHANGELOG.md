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
