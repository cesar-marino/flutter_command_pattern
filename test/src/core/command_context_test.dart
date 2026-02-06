import 'package:flutter_command_pattern/flutter_command_pattern.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommandContext', () {
    late Command testCommand;

    setUp(() {
      testCommand = Command(() async {});
    });

    tearDown(() {
      testCommand.dispose();
    });

    test('should create context with command and state', () {
      const state = CommandInitial();
      final context = CommandContext(command: testCommand, state: state);

      expect(context.command, equals(testCommand));
      expect(context.state, equals(state));
    });

    group('isRunning', () {
      test('should return true when state is CommandRunning', () {
        final context = CommandContext(
          command: testCommand,
          state: const CommandRunning(),
        );

        expect(context.isRunning, isTrue);
      });

      test('should return false when state is not CommandRunning', () {
        final context = CommandContext(
          command: testCommand,
          state: const CommandInitial(),
        );

        expect(context.isRunning, isFalse);
      });
    });

    group('isSuccess', () {
      test('should return true when state is CommandSuccess', () {
        final context = CommandContext(
          command: testCommand,
          state: const CommandSuccess(),
        );

        expect(context.isSuccess, isTrue);
      });

      test('should return false when state is not CommandSuccess', () {
        final context = CommandContext(
          command: testCommand,
          state: const CommandInitial(),
        );

        expect(context.isSuccess, isFalse);
      });
    });

    group('hasError', () {
      test('should return true when state is CommandFailure', () {
        final context = CommandContext(
          command: testCommand,
          state: const CommandFailure(CommandError(message: 'error')),
        );

        expect(context.hasError, isTrue);
      });

      test('should return false when state is not CommandFailure', () {
        final context = CommandContext(
          command: testCommand,
          state: const CommandInitial(),
        );

        expect(context.hasError, isFalse);
      });
    });

    group('error', () {
      test('should return error when state is CommandFailure', () {
        const error = CommandError(message: 'test error');
        final context = CommandContext(
          command: testCommand,
          state: const CommandFailure(error),
        );

        expect(context.error, equals(error));
      });

      test('should return null when state is not CommandFailure', () {
        final context = CommandContext(
          command: testCommand,
          state: const CommandInitial(),
        );

        expect(context.error, isNull);
      });
    });

    test('state can be updated', () {
      final context = CommandContext(
        command: testCommand,
        state: const CommandInitial(),
      );

      expect(context.state, isA<CommandInitial>());

      context.state = const CommandRunning();
      expect(context.state, isA<CommandRunning>());

      context.state = const CommandSuccess();
      expect(context.state, isA<CommandSuccess>());
    });

    test('toString should contain command type and state type', () {
      final context = CommandContext(
        command: testCommand,
        state: const CommandInitial(),
      );

      final str = context.toString();
      expect(str, contains('CommandContext'));
      expect(str, contains('Command'));
      expect(str, contains('CommandInitial'));
    });
  });
}
