import 'package:flutter_command_pattern/flutter_command_pattern.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommandState', () {
    group('CommandInitial', () {
      test('should be equal to another CommandInitial instance', () {
        const state1 = CommandInitial();
        const state2 = CommandInitial();

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    group('CommandRunning', () {
      test('should be equal to another CommandRunning instance', () {
        const state1 = CommandRunning();
        const state2 = CommandRunning();

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    group('CommandSuccess', () {
      test('should be equal to another CommandSuccess instance', () {
        const state1 = CommandSuccess();
        const state2 = CommandSuccess();

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    group('CommandFailure', () {
      test('should contain error information', () {
        final error = Exception('Test error');
        final state = CommandFailure(error);

        expect(state.error, equals(error));
        expect(state.stackTrace, isNull);
      });

      test('should contain error and stackTrace', () {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;
        final state = CommandFailure(error, stackTrace);

        expect(state.error, equals(error));
        expect(state.stackTrace, equals(stackTrace));
      });

      test('should be equal when error and stackTrace match', () {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;
        final state1 = CommandFailure(error, stackTrace);
        final state2 = CommandFailure(error, stackTrace);

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when errors differ', () {
        final state1 = CommandFailure(Exception('Error 1'));
        final state2 = CommandFailure(Exception('Error 2'));

        expect(state1, isNot(equals(state2)));
      });

      test('toString should contain error information', () {
        final error = Exception('Test error');
        final state = CommandFailure(error);

        expect(state.toString(), contains('CommandFailure'));
        expect(state.toString(), contains('Test error'));
      });
    });

    group('Type checking', () {
      test('states should be of correct types', () {
        expect(const CommandInitial(), isA<CommandState>());
        expect(const CommandRunning(), isA<CommandState>());
        expect(const CommandSuccess(), isA<CommandState>());
        expect(CommandFailure(Exception()), isA<CommandState>());
      });

      test('states should not be equal across different types', () {
        const initial = CommandInitial();
        const running = CommandRunning();
        const success = CommandSuccess();
        final failure = CommandFailure(Exception());

        expect(initial, isNot(equals(running)));
        expect(initial, isNot(equals(success)));
        expect(initial, isNot(equals(failure)));
        expect(running, isNot(equals(success)));
        expect(running, isNot(equals(failure)));
        expect(success, isNot(equals(failure)));
      });
    });
  });
}
