import 'package:flutter_command_pattern/flutter_command_pattern.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommandBase', () {
    late Command command;

    setUp(() {
      CommandPipelineRegistry.clear();
      CommandObserverRegistry.clear();
    });

    tearDown(() {
      command.dispose();
      CommandPipelineRegistry.clear();
      CommandObserverRegistry.clear();
    });

    test('should start with CommandInitial state', () {
      command = Command(() async {});

      expect(command.state, isA<CommandInitial>());
      expect(command.isRunning, isFalse);
      expect(command.hasError, isFalse);
      expect(command.error, isNull);
    });

    test('should transition to CommandRunning when executing', () async {
      // var stateWhenCalled = const CommandInitial();
      CommandState? stateWhenCalled;

      command = Command(() async {
        stateWhenCalled = command.state;
        await Future.delayed(const Duration(milliseconds: 10));
      });

      final future = command.execute();
      await Future.delayed(Duration.zero); // Allow state to update

      expect(command.state, isA<CommandRunning>());
      expect(command.isRunning, isTrue);

      await future;
      expect(stateWhenCalled, isA<CommandRunning>());
    });

    test('should transition to CommandSuccess on successful execution',
        () async {
      command = Command(() async {
        await Future.delayed(const Duration(milliseconds: 10));
      });

      await command.execute();

      expect(command.state, isA<CommandSuccess>());
      expect(command.isRunning, isFalse);
      expect(command.hasError, isFalse);
    });

    test('should transition to CommandFailure on error', () async {
      final error = Exception('Test error');
      command = Command(() async {
        throw error;
      });

      await command.execute();

      expect(command.state, isA<CommandFailure>());
      expect(command.hasError, isTrue);
      expect(command.error, equals(error));
      expect(command.isRunning, isFalse);
    });

    test('should capture stackTrace on error', () async {
      command = Command(() async {
        throw Exception('Test error');
      });

      await command.execute();

      final failure = command.state as CommandFailure;
      expect(failure.stackTrace, isNotNull);
    });

    test('should not execute concurrently', () async {
      var executionCount = 0;

      command = Command(() async {
        executionCount++;
        await Future.delayed(const Duration(milliseconds: 50));
      });

      // Start first execution
      final future1 = command.execute();

      // Try to start second execution immediately
      await Future.delayed(const Duration(milliseconds: 10));
      final future2 = command.execute();

      await Future.wait([future1, future2]);

      expect(executionCount, equals(1));
    });

    test('should notify listeners on state change', () async {
      final states = <CommandState>[];
      command = Command(() async {
        await Future.delayed(const Duration(milliseconds: 10));
      });

      command.addListener(() {
        states.add(command.state);
      });

      await command.execute();

      expect(states.length, greaterThanOrEqualTo(2));
      expect(states[0], isA<CommandRunning>());
      expect(states.last, isA<CommandSuccess>());
    });

    test('should execute pipelines in correct order', () async {
      final executionOrder = <String>[];

      CommandPipelineRegistry.addPipeline((context, next) async {
        executionOrder.add('pipeline1-before');
        await next();
        executionOrder.add('pipeline1-after');
      });

      CommandPipelineRegistry.addPipeline((context, next) async {
        executionOrder.add('pipeline2-before');
        await next();
        executionOrder.add('pipeline2-after');
      });

      command = Command(() async {
        executionOrder.add('action');
      });

      await command.execute();

      expect(executionOrder, [
        'pipeline1-before',
        'pipeline2-before',
        'action',
        'pipeline2-after',
        'pipeline1-after',
      ]);
    });

    test('should notify global observers', () async {
      final observedContexts = <CommandContext>[];

      CommandObserverRegistry.addObserver((context) {
        observedContexts.add(context);
      });

      command = Command(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await command.execute();

      expect(observedContexts.length, greaterThanOrEqualTo(2));
      expect(observedContexts[0].state, isA<CommandRunning>());
      expect(observedContexts.last.state, isA<CommandSuccess>());
    });

    test('reset should return command to initial state', () async {
      command = Command(() async {});

      await command.execute();
      expect(command.state, isA<CommandSuccess>());

      command.reset();
      expect(command.state, isA<CommandInitial>());
      expect(command.isRunning, isFalse);
      expect(command.hasError, isFalse);
      expect(command.error, isNull);
    });

    test('reset should notify listeners', () async {
      var notificationCount = 0;
      command = Command(() async {});

      command.addListener(() {
        notificationCount++;
      });

      await command.execute();
      final countAfterExecute = notificationCount;

      command.reset();

      expect(notificationCount, equals(countAfterExecute + 1));
    });

    test('can execute again after completion', () async {
      var executionCount = 0;
      command = Command(() async {
        executionCount++;
      });

      await command.execute();
      expect(executionCount, equals(1));

      await command.execute();
      expect(executionCount, equals(2));
    });

    test('can execute again after failure', () async {
      var shouldFail = true;
      var executionCount = 0;

      command = Command(() async {
        executionCount++;
        if (shouldFail) {
          throw Exception('Intentional error');
        }
      });

      await command.execute();
      expect(command.hasError, isTrue);
      expect(executionCount, equals(1));

      shouldFail = false;
      await command.execute();
      expect(command.state, isA<CommandSuccess>());
      expect(executionCount, equals(2));
    });
  });
}
