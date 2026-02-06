import 'package:flutter/material.dart';
import 'package:flutter_command_pattern/flutter_command_pattern.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Integration Tests', () {
    setUp(() {
      CommandPipelineRegistry.clear();
      CommandObserverRegistry.clear();
    });

    tearDown(() {
      CommandPipelineRegistry.clear();
      CommandObserverRegistry.clear();
    });

    test('complete flow: command with pipeline and observer', () async {
      final executionLog = <String>[];

      // Setup pipeline
      CommandPipelineRegistry.addPipeline((context, next) async {
        executionLog.add('pipeline-before');
        await next();
        executionLog.add('pipeline-after');
      });

      // Setup observer
      CommandObserverRegistry.addObserver((context) {
        executionLog.add('observer-${context.state.runtimeType}');
      });

      // Execute command
      final command = Command(() async {
        executionLog.add('command-action');
      });

      await command.execute();

      expect(executionLog, [
        'pipeline-before',
        'observer-CommandRunning',
        'command-action',
        'observer-CommandSuccess',
        'pipeline-after',
      ]);

      command.dispose();
    });

    test('multiple pipelines execute in correct order', () async {
      final executionLog = <String>[];

      CommandPipelineRegistry.addPipeline((context, next) async {
        executionLog.add('pipeline1-before');
        await next();
        executionLog.add('pipeline1-after');
      });

      CommandPipelineRegistry.addPipeline((context, next) async {
        executionLog.add('pipeline2-before');
        await next();
        executionLog.add('pipeline2-after');
      });

      CommandPipelineRegistry.addPipeline((context, next) async {
        executionLog.add('pipeline3-before');
        await next();
        executionLog.add('pipeline3-after');
      });

      final command = Command(() async {
        executionLog.add('action');
      });

      await command.execute();

      expect(executionLog, [
        'pipeline1-before',
        'pipeline2-before',
        'pipeline3-before',
        'action',
        'pipeline3-after',
        'pipeline2-after',
        'pipeline1-after',
      ]);

      command.dispose();
    });

    test('pipeline can log execution time', () async {
      final executionTimes = <int>[];

      CommandPipelineRegistry.addPipeline((context, next) async {
        final stopwatch = Stopwatch()..start();
        await next();
        stopwatch.stop();
        executionTimes.add(stopwatch.elapsedMilliseconds);
      });

      final command = Command(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });

      await command.execute();

      expect(executionTimes.length, equals(1));
      expect(executionTimes.first, greaterThanOrEqualTo(50));

      command.dispose();
    });

    test('observer can track all command executions', () async {
      final commandTypes = <String>[];

      CommandObserverRegistry.addObserver((context) {
        if (context.state is CommandSuccess) {
          commandTypes.add(context.command.runtimeType.toString());
        }
      });

      final command1 = Command(() async {});
      final command2 = CommandWithParams<int>((param) async {});

      await command1.execute();
      await command2.execute(42);
      await command1.execute();

      expect(commandTypes, [
        'Command',
        'CommandWithParams<int>',
        'Command',
      ]);

      command1.dispose();
      command2.dispose();
    });

    test('pipeline can modify context state information', () async {
      CommandState? stateBeforeAction;
      CommandState? stateAfterAction;

      CommandPipelineRegistry.addPipeline((context, next) async {
        stateBeforeAction = context.state;
        await next();
        stateAfterAction = context.state;
      });

      final command = Command(() async {});

      await command.execute();

      expect(stateBeforeAction, isA<CommandInitial>());
      expect(stateAfterAction, isA<CommandSuccess>());

      command.dispose();
    });

    test('error in command is properly propagated through pipeline', () async {
      final error = Exception('Test error');
      final states = <CommandState>[];

      CommandPipelineRegistry.addPipeline((context, next) async {
        await next();
        states.add(context.state);
      });

      final command = Command(() async {
        throw error;
      });

      await command.execute();

      expect(states.last, isA<CommandFailure>());
      expect((states.last as CommandFailure).error.initialError, equals(error));
      expect((states.last as CommandFailure).originalError, equals(error));

      command.dispose();
    });

    testWidgets('full widget integration test', (tester) async {
      final executionLog = <String>[];

      CommandPipelineRegistry.addPipeline((context, next) async {
        executionLog.add('pipeline');
        await next();
      });

      CommandObserverRegistry.addObserver((context) {
        executionLog.add('observer-${context.state.runtimeType}');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final command = Command(() async {
                  executionLog.add('command');
                  await Future.delayed(const Duration(milliseconds: 10));
                });

                command.observe(
                  context,
                  onLoading: (_) => executionLog.add('widget-loading'),
                  onSuccess: (_) => executionLog.add('widget-success'),
                );

                return ElevatedButton(
                  onPressed: command.execute,
                  child: const Text('Execute'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Execute'));
      await tester.pumpAndSettle();

      expect(executionLog, [
        'pipeline',
        'observer-CommandRunning',
        'widget-loading',
        'command',
        'observer-CommandSuccess',
        'widget-success',
      ]);
    });

    test('multiple commands can share same pipelines and observers', () async {
      var pipelineCallCount = 0;
      var observerCallCount = 0;

      CommandPipelineRegistry.addPipeline((context, next) async {
        pipelineCallCount++;
        await next();
      });

      CommandObserverRegistry.addObserver((context) {
        if (context.state is CommandSuccess) {
          observerCallCount++;
        }
      });

      final command1 = Command(() async {});
      final command2 = Command(() async {});
      final command3 = CommandWithParams<String>((param) async {});

      await command1.execute();
      await command2.execute();
      await command3.execute('test');

      expect(pipelineCallCount, equals(3));
      expect(observerCallCount, equals(3));

      command1.dispose();
      command2.dispose();
      command3.dispose();
    });

    test('command can be reset and reused', () async {
      var executionCount = 0;

      final command = Command(() async {
        executionCount++;
      });

      await command.execute();
      expect(command.state, isA<CommandSuccess>());
      expect(executionCount, equals(1));

      command.reset();
      expect(command.state, isA<CommandInitial>());

      await command.execute();
      expect(command.state, isA<CommandSuccess>());
      expect(executionCount, equals(2));

      command.dispose();
    });

    test('complex scenario: authentication flow', () async {
      final events = <String>[];

      // Logging pipeline
      CommandPipelineRegistry.addPipeline((context, next) async {
        events.add('log: ${context.command.runtimeType} started');
        await next();
        events.add('log: ${context.command.runtimeType} finished');
      });

      // Analytics pipeline
      CommandPipelineRegistry.addPipeline((context, next) async {
        await next();
        if (context.state is CommandSuccess) {
          events.add('analytics: ${context.command.runtimeType} succeeded');
        }
      });

      // Error tracking observer
      CommandObserverRegistry.addObserver((context) {
        if (context.state is CommandFailure) {
          events.add('error-tracker: ${context.error}');
        }
      });

      // Login command
      final loginCommand =
          CommandWithParams<Map<String, String>>((credentials) async {
        events.add('action: validating credentials');
        if (credentials['email'] != 'test@example.com') {
          throw Exception('Invalid credentials');
        }
        events.add('action: login successful');
      });

      // Successful login
      await loginCommand
          .execute({'email': 'test@example.com', 'password': '123'});

      expect(events, [
        'log: CommandWithParams<Map<String, String>> started',
        'action: validating credentials',
        'action: login successful',
        'analytics: CommandWithParams<Map<String, String>> succeeded',
        'log: CommandWithParams<Map<String, String>> finished',
      ]);

      events.clear();

      // Failed login
      await loginCommand
          .execute({'email': 'wrong@example.com', 'password': '123'});

      expect(
        events.firstWhere(
          (e) => e.startsWith('error-tracker: CommandError'),
          orElse: () => '',
        ),
        isNotEmpty,
      );

      loginCommand.dispose();
    });
  });
}
