import 'package:flutter_command_pattern/flutter_command_pattern.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommandObserverRegistry', () {
    setUp(() {
      CommandObserverRegistry.clear();
    });

    tearDown(() {
      CommandObserverRegistry.clear();
    });

    test('should start with no observers', () {
      expect(CommandObserverRegistry.observers, isEmpty);
    });

    test('should add observer', () {
      void observer(CommandContext context) {}

      CommandObserverRegistry.addObserver(observer);

      expect(CommandObserverRegistry.observers.length, equals(1));
      expect(CommandObserverRegistry.observers.first, equals(observer));
    });

    test('should add multiple observers', () {
      void observer1(CommandContext context) {}
      void observer2(CommandContext context) {}

      CommandObserverRegistry.addObserver(observer1);
      CommandObserverRegistry.addObserver(observer2);

      expect(CommandObserverRegistry.observers.length, equals(2));
      expect(CommandObserverRegistry.observers[0], equals(observer1));
      expect(CommandObserverRegistry.observers[1], equals(observer2));
    });

    test('should return unmodifiable list', () {
      void observer(CommandContext context) {}

      CommandObserverRegistry.addObserver(observer);

      expect(
        () => CommandObserverRegistry.observers.add(observer),
        throwsUnsupportedError,
      );
    });

    test('should remove specific observer', () {
      void observer1(CommandContext context) {}
      void observer2(CommandContext context) {}

      CommandObserverRegistry.addObserver(observer1);
      CommandObserverRegistry.addObserver(observer2);

      final removed = CommandObserverRegistry.removeObserver(observer1);

      expect(removed, isTrue);
      expect(CommandObserverRegistry.observers.length, equals(1));
      expect(CommandObserverRegistry.observers.first, equals(observer2));
    });

    test('removeObserver should return false if observer not found', () {
      void observer1(CommandContext context) {}
      void observer2(CommandContext context) {}

      CommandObserverRegistry.addObserver(observer1);

      final removed = CommandObserverRegistry.removeObserver(observer2);

      expect(removed, isFalse);
      expect(CommandObserverRegistry.observers.length, equals(1));
    });

    test('should clear all observers', () {
      CommandObserverRegistry.addObserver((context) {});
      CommandObserverRegistry.addObserver((context) {});

      expect(CommandObserverRegistry.observers.length, equals(2));

      CommandObserverRegistry.clear();

      expect(CommandObserverRegistry.observers, isEmpty);
    });

    test('observers should be notified on command state changes', () async {
      final states = <CommandState>[];

      CommandObserverRegistry.addObserver((context) {
        states.add(context.state);
      });

      final command = Command(() async {
        await Future.delayed(const Duration(milliseconds: 10));
      });

      await command.execute();

      expect(states.length, greaterThanOrEqualTo(2));
      expect(states.first, isA<CommandRunning>());
      expect(states.last, isA<CommandSuccess>());

      command.dispose();
    });

    test('multiple observers should all be notified', () async {
      var observer1Called = false;
      var observer2Called = false;

      CommandObserverRegistry.addObserver((context) {
        observer1Called = true;
      });

      CommandObserverRegistry.addObserver((context) {
        observer2Called = true;
      });

      final command = Command(() async {});

      await command.execute();

      expect(observer1Called, isTrue);
      expect(observer2Called, isTrue);

      command.dispose();
    });

    test('observers should be notified of command failures', () async {
      CommandError? observedError;

      CommandObserverRegistry.addObserver((context) {
        if (context.state is CommandFailure) {
          observedError = context.error;
        }
      });

      final error = Exception('Test error');
      final command = Command(() async {
        throw error;
      });

      await command.execute();

      expect(observedError, isNotNull);
      expect(observedError!.initialError, equals(error));

      command.dispose();
    });

    test('observers should receive context with command information', () async {
      CommandBase? observedCommand;
      CommandState? observedState;

      CommandObserverRegistry.addObserver((context) {
        observedCommand = context.command;
        observedState = context.state;
      });

      final command = Command(() async {});

      await command.execute();

      expect(observedCommand, equals(command));
      expect(observedState, isNotNull);

      command.dispose();
    });

    test('observers should be called for every command execution', () async {
      var callCount = 0;

      CommandObserverRegistry.addObserver((context) {
        if (context.state is CommandSuccess) {
          callCount++;
        }
      });

      final command1 = Command(() async {});
      final command2 = Command(() async {});

      await command1.execute();
      await command2.execute();
      await command1.execute();

      expect(callCount, equals(3));

      command1.dispose();
      command2.dispose();
    });

    test('observers should be notified in order they were added', () async {
      final callOrder = <int>[];

      CommandObserverRegistry.addObserver((context) {
        callOrder.add(1);
      });

      CommandObserverRegistry.addObserver((context) {
        callOrder.add(2);
      });

      CommandObserverRegistry.addObserver((context) {
        callOrder.add(3);
      });

      final command = Command(() async {});

      await command.execute();

      // Each observer is called twice (running and success)
      expect(callOrder.length, greaterThanOrEqualTo(6));
      expect(callOrder.sublist(0, 3), equals([1, 2, 3]));

      command.dispose();
    });

    test('observer error should not prevent command execution', () async {
      var commandCompleted = false;

      CommandObserverRegistry.addObserver((context) {
        throw Exception('Observer error');
      });

      final command = Command(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        commandCompleted = true;
      });

      // This should not throw even though observer throws
      await expectLater(
        command.execute(),
        completes,
      );

      expect(commandCompleted, isTrue);

      command.dispose();
    });
  });
}
