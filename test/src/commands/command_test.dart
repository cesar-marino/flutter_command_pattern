import 'package:flutter_command_pattern/flutter_command_pattern.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Command', () {
    late Command command;

    tearDown(() {
      command.dispose();
    });

    test('should execute action', () async {
      var executed = false;

      command = Command(() async {
        executed = true;
      });

      await command.execute();

      expect(executed, isTrue);
      expect(command.state, isA<CommandSuccess>());
    });

    test('should execute async action', () async {
      var value = 0;

      command = Command(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        value = 42;
      });

      await command.execute();

      expect(value, equals(42));
      expect(command.state, isA<CommandSuccess>());
    });

    test('should handle action that throws error', () async {
      final error = Exception('Test error');

      command = Command(() async {
        throw error;
      });

      await command.execute();

      expect(command.hasError, isTrue);
      expect(command.error, isNotNull);
      expect(command.error!.message, contains('Test error'));
      expect(command.error!.initialError, equals(error));
      expect(command.state, isA<CommandFailure>());
    });

    test('should handle action that throws during async operation', () async {
      command = Command(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        throw Exception('Delayed error');
      });

      await command.execute();

      expect(command.hasError, isTrue);
      expect(command.state, isA<CommandFailure>());
    });

    test('should be reusable after success', () async {
      var count = 0;

      command = Command(() async {
        count++;
      });

      await command.execute();
      expect(count, equals(1));

      await command.execute();
      expect(count, equals(2));

      await command.execute();
      expect(count, equals(3));
    });

    test('should be reusable after failure', () async {
      var shouldFail = true;
      var count = 0;

      command = Command(() async {
        count++;
        if (shouldFail) {
          throw Exception('Error');
        }
      });

      // First execution fails
      await command.execute();
      expect(command.hasError, isTrue);
      expect(count, equals(1));

      // Second execution succeeds
      shouldFail = false;
      await command.execute();
      expect(command.state, isA<CommandSuccess>());
      expect(count, equals(2));
    });

    test('execute returns Future<void>', () async {
      command = Command(() async {});

      final result = command.execute();
      expect(result, isA<Future<void>>());

      await result;
    });

    test('should handle synchronous errors in async action', () async {
      command = Command(() async {
        throw Exception('Immediate error');
      });

      await command.execute();

      expect(command.hasError, isTrue);
    });

    test('multiple sequential executions should all complete', () async {
      var count = 0;

      command = Command(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        count++;
      });

      await command.execute();
      await command.execute();
      await command.execute();

      expect(count, equals(3));
    });
  });
}
