import 'package:flutter_command_pattern/flutter_command_pattern.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommandPipelineRegistry', () {
    setUp(() {
      CommandPipelineRegistry.clear();
    });

    tearDown(() {
      CommandPipelineRegistry.clear();
    });

    test('should start with no pipelines', () {
      expect(CommandPipelineRegistry.pipelines, isEmpty);
    });

    test('should add pipeline', () {
      Future<void> pipeline(CommandContext context, PipelineNext next) async {
        await next();
      }

      CommandPipelineRegistry.addPipeline(pipeline);

      expect(CommandPipelineRegistry.pipelines.length, equals(1));
      expect(CommandPipelineRegistry.pipelines.first, equals(pipeline));
    });

    test('should add multiple pipelines', () {
      Future<void> pipeline1(CommandContext context, PipelineNext next) async {
        await next();
      }

      Future<void> pipeline2(CommandContext context, PipelineNext next) async {
        await next();
      }

      CommandPipelineRegistry.addPipeline(pipeline1);
      CommandPipelineRegistry.addPipeline(pipeline2);

      expect(CommandPipelineRegistry.pipelines.length, equals(2));
      expect(CommandPipelineRegistry.pipelines[0], equals(pipeline1));
      expect(CommandPipelineRegistry.pipelines[1], equals(pipeline2));
    });

    test('should return unmodifiable list', () {
      Future<void> pipeline(CommandContext context, PipelineNext next) async {
        await next();
      }

      CommandPipelineRegistry.addPipeline(pipeline);

      expect(
        () => CommandPipelineRegistry.pipelines.add(pipeline),
        throwsUnsupportedError,
      );
    });

    test('should remove specific pipeline', () {
      Future<void> pipeline1(CommandContext context, PipelineNext next) async {
        await next();
      }

      Future<void> pipeline2(CommandContext context, PipelineNext next) async {
        await next();
      }

      CommandPipelineRegistry.addPipeline(pipeline1);
      CommandPipelineRegistry.addPipeline(pipeline2);

      final removed = CommandPipelineRegistry.removePipeline(pipeline1);

      expect(removed, isTrue);
      expect(CommandPipelineRegistry.pipelines.length, equals(1));
      expect(CommandPipelineRegistry.pipelines.first, equals(pipeline2));
    });

    test('removePipeline should return false if pipeline not found', () {
      Future<void> pipeline1(CommandContext context, PipelineNext next) async {
        await next();
      }

      Future<void> pipeline2(CommandContext context, PipelineNext next) async {
        await next();
      }

      CommandPipelineRegistry.addPipeline(pipeline1);

      final removed = CommandPipelineRegistry.removePipeline(pipeline2);

      expect(removed, isFalse);
      expect(CommandPipelineRegistry.pipelines.length, equals(1));
    });

    test('should clear all pipelines', () {
      CommandPipelineRegistry.addPipeline((context, next) async {
        await next();
      });

      CommandPipelineRegistry.addPipeline((context, next) async {
        await next();
      });

      expect(CommandPipelineRegistry.pipelines.length, equals(2));

      CommandPipelineRegistry.clear();

      expect(CommandPipelineRegistry.pipelines, isEmpty);
    });

    test('pipelines should execute in order', () async {
      final executionOrder = <int>[];

      CommandPipelineRegistry.addPipeline((context, next) async {
        executionOrder.add(1);
        await next();
      });

      CommandPipelineRegistry.addPipeline((context, next) async {
        executionOrder.add(2);
        await next();
      });

      CommandPipelineRegistry.addPipeline((context, next) async {
        executionOrder.add(3);
        await next();
      });

      final command = Command(() async {
        executionOrder.add(0);
      });

      await command.execute();

      expect(executionOrder, equals([1, 2, 3, 0]));

      command.dispose();
    });

    test('pipelines should be able to modify context state', () async {
      CommandPipelineRegistry.addPipeline((context, next) async {
        expect(context.state, isA<CommandInitial>());
        await next();
        expect(context.state, isA<CommandSuccess>());
      });

      final command = Command(() async {});

      await command.execute();

      command.dispose();
    });

    test('pipelines should execute even if command throws', () async {
      var pipelineExecuted = false;

      CommandPipelineRegistry.addPipeline((context, next) async {
        pipelineExecuted = true;
        await next();
      });

      final command = Command(() async {
        throw Exception('Test error');
      });

      await command.execute();

      expect(pipelineExecuted, isTrue);

      command.dispose();
    });

    test('pipeline can access command information', () async {
      String? commandType;

      CommandPipelineRegistry.addPipeline((context, next) async {
        commandType = context.command.runtimeType.toString();
        await next();
      });

      final command = Command(() async {});

      await command.execute();

      expect(commandType, equals('Command'));

      command.dispose();
    });

    test('multiple commands should use same pipelines', () async {
      var executionCount = 0;

      CommandPipelineRegistry.addPipeline((context, next) async {
        executionCount++;
        await next();
      });

      final command1 = Command(() async {});
      final command2 = Command(() async {});

      await command1.execute();
      await command2.execute();

      expect(executionCount, equals(2));

      command1.dispose();
      command2.dispose();
    });
  });
}
