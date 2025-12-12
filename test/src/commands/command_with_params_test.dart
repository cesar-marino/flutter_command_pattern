import 'package:flutter_command_pattern/flutter_command_pattern.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommandWithParams', () {
    test('should execute action with String parameter', () async {
      String? receivedParam;

      final command = CommandWithParams<String>((param) async {
        receivedParam = param;
      });

      await command.execute('test value');

      expect(receivedParam, equals('test value'));
      expect(command.state, isA<CommandSuccess>());

      command.dispose();
    });

    test('should execute action with int parameter', () async {
      int? receivedParam;

      final command = CommandWithParams<int>((param) async {
        receivedParam = param;
      });

      await command.execute(42);

      expect(receivedParam, equals(42));
      expect(command.state, isA<CommandSuccess>());

      command.dispose();
    });

    test('should execute action with custom object parameter', () async {
      final testObject = TestObject(id: 1, name: 'Test');
      TestObject? receivedParam;

      final command = CommandWithParams<TestObject>((param) async {
        receivedParam = param;
      });

      await command.execute(testObject);

      expect(receivedParam, equals(testObject));
      expect(receivedParam?.id, equals(1));
      expect(receivedParam?.name, equals('Test'));

      command.dispose();
    });

    test('should handle async action with parameter', () async {
      final results = <String>[];

      final command = CommandWithParams<String>((param) async {
        await Future.delayed(const Duration(milliseconds: 10));
        results.add(param);
      });

      await command.execute('first');
      await command.execute('second');
      await command.execute('third');

      expect(results, equals(['first', 'second', 'third']));

      command.dispose();
    });

    test('should handle error with parameter', () async {
      final command = CommandWithParams<String>((param) async {
        throw Exception('Error with param: $param');
      });

      await command.execute('test');

      expect(command.hasError, isTrue);
      expect(command.error.toString(), contains('test'));

      command.dispose();
    });

    test('should be reusable with different parameters', () async {
      final results = <int>[];

      final command = CommandWithParams<int>((param) async {
        results.add(param * 2);
      });

      await command.execute(1);
      await command.execute(2);
      await command.execute(3);

      expect(results, equals([2, 4, 6]));

      command.dispose();
    });

    test('should handle nullable parameters', () async {
      String? receivedParam;

      final command = CommandWithParams<String?>((param) async {
        receivedParam = param;
      });

      await command.execute(null);
      expect(receivedParam, isNull);

      await command.execute('not null');
      expect(receivedParam, equals('not null'));

      command.dispose();
    });

    test('should handle List parameters', () async {
      List<int>? receivedParam;

      final command = CommandWithParams<List<int>>((param) async {
        receivedParam = param;
      });

      await command.execute([1, 2, 3]);

      expect(receivedParam, equals([1, 2, 3]));

      command.dispose();
    });

    test('should handle Map parameters', () async {
      Map<String, dynamic>? receivedParam;

      final command = CommandWithParams<Map<String, dynamic>>((param) async {
        receivedParam = param;
      });

      await command.execute({'key': 'value', 'number': 42});

      expect(receivedParam?['key'], equals('value'));
      expect(receivedParam?['number'], equals(42));

      command.dispose();
    });

    test('should transition through correct states with parameter', () async {
      final states = <CommandState>[];

      final command = CommandWithParams<String>((param) async {
        await Future.delayed(const Duration(milliseconds: 10));
      });

      command.addListener(() {
        states.add(command.state);
      });

      await command.execute('test');

      expect(states[0], isA<CommandRunning>());
      expect(states.last, isA<CommandSuccess>());

      command.dispose();
    });

    test('should prevent concurrent executions even with different params',
        () async {
      var executionCount = 0;

      final command = CommandWithParams<int>((param) async {
        executionCount++;
        await Future.delayed(const Duration(milliseconds: 50));
      });

      final future1 = command.execute(1);
      await Future.delayed(const Duration(milliseconds: 10));
      final future2 = command.execute(2);

      await Future.wait([future1, future2]);

      expect(executionCount, equals(1));

      command.dispose();
    });

    test('should work with complex generic types', () async {
      Future<String>? receivedParam;

      final command = CommandWithParams<Future<String>>((param) async {
        receivedParam = param;
      });

      final futureParam = Future.value('async result');
      await command.execute(futureParam);

      expect(await receivedParam, equals('async result'));

      command.dispose();
    });
  });
}

// Helper class for testing
class TestObject {
  final int id;
  final String name;

  TestObject({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestObject && id == other.id && name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}
