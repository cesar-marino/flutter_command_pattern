import 'package:flutter_command_pattern/flutter_command_pattern.dart';
import 'package:flutter_test/flutter_test.dart';

// Exceções customizadas para teste
class CustomNetworkException implements Exception {
  final String message;
  final int? statusCode;

  CustomNetworkException(this.message, [this.statusCode]);

  @override
  String toString() => 'CustomNetworkException: $message (Status: $statusCode)';
}

class ValidationException implements Exception {
  final String field;
  final String message;

  ValidationException(this.field, this.message);

  @override
  String toString() => 'ValidationException: $field - $message';
}

// Comando de teste
class TestCommand extends Command {
  TestCommand(void Function() action) : super(() async => action());
}

void main() {
  group('CommandError and CommandErrorMapperRegistry', () {
    // Limpar registros antes de cada teste
    setUp(() {
      CommandErrorMapperRegistry.clear();
    });

    group('CommandError', () {
      test('criar CommandError com todos os atributos', () {
        final error = CommandError(
          code: 'TEST_ERROR',
          message: 'Test message',
          initialError: Exception('original'),
        );

        expect(error.code, equals('TEST_ERROR'));
        expect(error.message, equals('Test message'));
        expect(error.initialError, isA<Exception>());
      });

      test('criar CommandError com atributos nulos', () {
        const error = CommandError();

        expect(error.code, isNull);
        expect(error.message, isNull);
        expect(error.initialError, isNull);
      });

      test('CommandError toString() funciona corretamente', () {
        final error = CommandError(
          code: 'TEST',
          message: 'message',
          initialError: Exception('error'),
        );

        final str = error.toString();
        expect(str, contains('TEST'));
        expect(str, contains('message'));
      });

      test('CommandError igualdade funciona', () {
        const error1 = CommandError(
          code: 'TEST',
          message: 'message',
        );
        const error2 = CommandError(
          code: 'TEST',
          message: 'message',
        );
        const error3 = CommandError(
          code: 'OTHER',
          message: 'message',
        );

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });

      test('CommandError hashCode funciona', () {
        const error1 = CommandError(
          code: 'TEST',
          message: 'message',
        );
        const error2 = CommandError(
          code: 'TEST',
          message: 'message',
        );

        expect(error1.hashCode, equals(error2.hashCode));
      });
    });

    group('CommandErrorMapperRegistry', () {
      test('registrar e recuperar mapper', () {
        CommandErrorMapperRegistry.register<CustomNetworkException>(
          (error) => CommandError(
            code: 'NETWORK_ERROR',
            message: error.message,
            initialError: error,
          ),
        );

        expect(
          CommandErrorMapperRegistry.hasMapper(CustomNetworkException),
          isTrue,
        );
      });

      test('mapper não registrado retorna false', () {
        expect(
          CommandErrorMapperRegistry.hasMapper(CustomNetworkException),
          isFalse,
        );
      });

      test('mapError usa mapper registrado', () {
        CommandErrorMapperRegistry.register<CustomNetworkException>(
          (error) => CommandError(
            code: 'NETWORK_${error.statusCode}',
            message: error.message,
            initialError: error,
          ),
        );

        final exception = CustomNetworkException('Connection failed', 500);
        final mappedError = CommandErrorMapperRegistry.mapError(exception);

        expect(mappedError.code, equals('NETWORK_500'));
        expect(mappedError.message, equals('Connection failed'));
        expect(mappedError.initialError, equals(exception));
      });

      test('mapError com exceção não registrada usa default', () {
        final exception = CustomNetworkException('Connection failed', 500);
        final mappedError = CommandErrorMapperRegistry.mapError(exception);

        expect(mappedError.message, contains('Connection failed'));
        expect(mappedError.initialError, equals(exception));
      });

      test('clear remove todos os mappers', () {
        CommandErrorMapperRegistry.register<CustomNetworkException>(
          (error) => const CommandError(code: 'NETWORK'),
        );
        CommandErrorMapperRegistry.register<ValidationException>(
          (error) => const CommandError(code: 'VALIDATION'),
        );

        expect(
          CommandErrorMapperRegistry.hasMapper(CustomNetworkException),
          isTrue,
        );

        CommandErrorMapperRegistry.clear();

        expect(
          CommandErrorMapperRegistry.hasMapper(CustomNetworkException),
          isFalse,
        );

        expect(
          CommandErrorMapperRegistry.hasMapper(ValidationException),
          isFalse,
        );
      });
    });

    group('Command Integration with Error Mapping', () {
      test('Command captura erro e mapeia corretamente', () async {
        CommandErrorMapperRegistry.register<CustomNetworkException>(
          (error) => CommandError(
            code: 'NETWORK_ERROR',
            message: error.message,
            initialError: error,
          ),
        );

        final command = TestCommand(() {
          throw CustomNetworkException('Network timeout', 503);
        });

        await command.execute();

        expect(command.hasError, isTrue);
        expect(command.error, isNotNull);
        expect(command.error!.code, equals('NETWORK_ERROR'));
        expect(command.error!.message, equals('Network timeout'));
      });

      test('Command com exceção não registrada usa default mapping', () async {
        final command = TestCommand(() {
          throw CustomNetworkException('Connection failed', 500);
        });

        await command.execute();

        expect(command.hasError, isTrue);
        expect(command.error, isNotNull);
        expect(command.error!.message, isNotEmpty);
      });

      test('Command bem sucedido retorna null no error', () async {
        final command = TestCommand(() {});

        await command.execute();

        expect(command.hasError, isFalse);
        expect(command.error, isNull);
      });

      test('Múltiplos mappers funcionam independentemente', () async {
        CommandErrorMapperRegistry.register<CustomNetworkException>(
          (error) => CommandError(
            code: 'NETWORK',
            message: 'Network: ${error.message}',
          ),
        );

        CommandErrorMapperRegistry.register<ValidationException>(
          (error) => CommandError(
            code: 'VALIDATION',
            message: 'Validation: ${error.field}',
          ),
        );

        final networkCommand = TestCommand(() {
          throw CustomNetworkException('Failed', 500);
        });

        final validationCommand = TestCommand(() {
          throw ValidationException('email', 'Invalid email');
        });

        await networkCommand.execute();
        await validationCommand.execute();

        expect(networkCommand.error!.code, equals('NETWORK'));
        expect(networkCommand.error!.message, contains('Network:'));

        expect(validationCommand.error!.code, equals('VALIDATION'));
        expect(validationCommand.error!.message, contains('Validation:'));
      });
    });
  });
}
