import 'package:flutter/material.dart';
import 'package:flutter_command_pattern/flutter_command_pattern.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommandObserver', () {
    testWidgets('should call onLoading when state is CommandRunning',
        (tester) async {
      var onLoadingCalled = false;
      BuildContext? receivedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final observer = CommandObserver(
                context: context,
                onLoading: (ctx) {
                  onLoadingCalled = true;
                  receivedContext = ctx;
                },
              );

              observer.observe(const CommandRunning());

              return Container();
            },
          ),
        ),
      );

      expect(onLoadingCalled, isTrue);
      expect(receivedContext, isNotNull);
    });

    testWidgets('should call onSuccess when state is CommandSuccess',
        (tester) async {
      var onSuccessCalled = false;
      BuildContext? receivedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final observer = CommandObserver(
                context: context,
                onSuccess: (ctx) {
                  onSuccessCalled = true;
                  receivedContext = ctx;
                },
              );

              observer.observe(const CommandSuccess());

              return Container();
            },
          ),
        ),
      );

      expect(onSuccessCalled, isTrue);
      expect(receivedContext, isNotNull);
    });

    testWidgets('should call onFailure when state is CommandFailure',
        (tester) async {
      var onFailureCalled = false;
      BuildContext? receivedContext;
      CommandError? receivedError;
      const error = CommandError(message: 'Test error');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final observer = CommandObserver(
                context: context,
                onFailure: (ctx, err) {
                  onFailureCalled = true;
                  receivedContext = ctx;
                  receivedError = err;
                },
              );

              observer.observe(const CommandFailure(error));

              return Container();
            },
          ),
        ),
      );

      expect(onFailureCalled, isTrue);
      expect(receivedContext, isNotNull);
      expect(receivedError, equals(error));
    });

    testWidgets('should not call any callback for CommandInitial',
        (tester) async {
      var onLoadingCalled = false;
      var onSuccessCalled = false;
      var onFailureCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final observer = CommandObserver(
                context: context,
                onLoading: (_) => onLoadingCalled = true,
                onSuccess: (_) => onSuccessCalled = true,
                onFailure: (_, __) => onFailureCalled = true,
              );

              observer.observe(const CommandInitial());

              return Container();
            },
          ),
        ),
      );

      expect(onLoadingCalled, isFalse);
      expect(onSuccessCalled, isFalse);
      expect(onFailureCalled, isFalse);
    });

    testWidgets('should work with null callbacks', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final observer = CommandObserver(context: context);

              // Should not throw
              observer.observe(const CommandRunning());
              observer.observe(const CommandSuccess());
              observer.observe(
                const CommandFailure(CommandError(message: 'error')),
              );

              return Container();
            },
          ),
        ),
      );

      // Test passes if no exception is thrown
    });

    testWidgets('should work with partial callbacks', (tester) async {
      var onSuccessCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final observer = CommandObserver(
                context: context,
                onSuccess: (_) => onSuccessCalled = true,
              );

              observer.observe(const CommandRunning());
              observer.observe(const CommandSuccess());
              observer.observe(
                const CommandFailure(CommandError(message: 'error')),
              );

              return Container();
            },
          ),
        ),
      );

      expect(onSuccessCalled, isTrue);
    });

    testWidgets('can show dialog on loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  final observer = CommandObserver(
                    context: context,
                    onLoading: (ctx) {
                      showDialog(
                        context: ctx,
                        builder: (_) => const AlertDialog(
                          title: Text('Loading'),
                        ),
                      );
                    },
                  );

                  observer.observe(const CommandRunning());
                },
                child: const Text('Trigger'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Loading'), findsOneWidget);
    });

    testWidgets('can show snackbar on failure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    final observer = CommandObserver(
                      context: context,
                      onFailure: (ctx, error) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      },
                    );

                    observer.observe(
                      const CommandFailure(CommandError(message: 'Test error')),
                    );
                  },
                  child: const Text('Trigger'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('callbacks receive correct context', (tester) async {
      BuildContext? capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final observer = CommandObserver(
                context: context,
                onSuccess: (ctx) {
                  capturedContext = ctx;
                },
              );

              observer.observe(const CommandSuccess());

              return Container();
            },
          ),
        ),
      );

      expect(capturedContext, isNotNull);
      expect(capturedContext, isA<BuildContext>());
    });
  });
}
