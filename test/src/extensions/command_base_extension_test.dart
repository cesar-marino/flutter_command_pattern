import 'package:flutter/material.dart';
import 'package:flutter_command_pattern/flutter_command_pattern.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommandBaseExtension', () {
    testWidgets('observe should call onLoading when command starts',
        (tester) async {
      var onLoadingCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final command = Command(() async {
                await Future.delayed(const Duration(milliseconds: 50));
              });

              command.observe(
                context,
                onLoading: (_) {
                  onLoadingCalled = true;
                },
              );

              return ElevatedButton(
                onPressed: command.execute,
                child: const Text('Execute'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Execute'));
      await tester.pump();

      expect(onLoadingCalled, isTrue);
    });

    testWidgets('observe should call onSuccess when command succeeds',
        (tester) async {
      var onSuccessCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final command = Command(() async {
                await Future.delayed(const Duration(milliseconds: 10));
              });

              command.observe(
                context,
                onSuccess: (_) {
                  onSuccessCalled = true;
                },
              );

              return ElevatedButton(
                onPressed: command.execute,
                child: const Text('Execute'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Execute'));
      await tester.pumpAndSettle();

      expect(onSuccessCalled, isTrue);
    });

    testWidgets('observe should call onFailure when command fails',
        (tester) async {
      var onFailureCalled = false;
      Object? capturedError;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final command = Command(() async {
                throw Exception('Test error');
              });

              command.observe(
                context,
                onFailure: (_, error) {
                  onFailureCalled = true;
                  capturedError = error;
                },
              );

              return ElevatedButton(
                onPressed: command.execute,
                child: const Text('Execute'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Execute'));
      await tester.pumpAndSettle();

      expect(onFailureCalled, isTrue);
      expect(capturedError, isA<Exception>());
    });

    testWidgets('observe should work with partial callbacks', (tester) async {
      var onSuccessCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final command = Command(() async {});

              command.observe(
                context,
                onSuccess: (_) {
                  onSuccessCalled = true;
                },
              );

              return ElevatedButton(
                onPressed: command.execute,
                child: const Text('Execute'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Execute'));
      await tester.pumpAndSettle();

      expect(onSuccessCalled, isTrue);
    });

    testWidgets('observe should handle multiple state transitions',
        (tester) async {
      final states = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final command = Command(() async {
                await Future.delayed(const Duration(milliseconds: 10));
              });

              command.observe(
                context,
                onLoading: (_) => states.add('loading'),
                onSuccess: (_) => states.add('success'),
              );

              return ElevatedButton(
                onPressed: command.execute,
                child: const Text('Execute'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Execute'));
      await tester.pumpAndSettle();

      expect(states, equals(['loading', 'success']));
    });

    testWidgets('observe can show and hide loading dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final command = Command(() async {
                await Future.delayed(const Duration(milliseconds: 50));
              });

              command.observe(
                context,
                onLoading: (ctx) {
                  showDialog(
                    context: ctx,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                onSuccess: (ctx) {
                  Navigator.of(ctx).pop();
                },
              );

              return ElevatedButton(
                onPressed: command.execute,
                child: const Text('Execute'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Execute'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('observe can navigate on success', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (context) => Builder(
                  builder: (context) {
                    final command = Command(() async {
                      await Future.delayed(const Duration(milliseconds: 10));
                    });

                    command.observe(
                      context,
                      onSuccess: (ctx) {
                        Navigator.of(ctx).pushNamed('/success');
                      },
                    );

                    return ElevatedButton(
                      onPressed: command.execute,
                      child: const Text('Execute'),
                    );
                  },
                ),
            '/success': (_) => const Scaffold(
                  body: Text('Success Page'),
                ),
          },
        ),
      );

      await tester.tap(find.text('Execute'));
      await tester.pumpAndSettle();

      expect(find.text('Success Page'), findsOneWidget);
    });

    testWidgets('observe can show snackbar on failure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final command = Command(() async {
                  throw Exception('Failed');
                });

                command.observe(
                  context,
                  onFailure: (ctx, error) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(error.toString())),
                    );
                  },
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
      await tester.pump();

      expect(find.text('Exception: Failed'), findsOneWidget);
    });

    testWidgets('observe works with CommandWithParams', (tester) async {
      var onSuccessCalled = false;
      String? receivedParam;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final command = CommandWithParams<String>((param) async {
                receivedParam = param;
              });

              command.observe(
                context,
                onSuccess: (_) {
                  onSuccessCalled = true;
                },
              );

              return ElevatedButton(
                onPressed: () => command.execute('test'),
                child: const Text('Execute'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Execute'));
      await tester.pumpAndSettle();

      expect(onSuccessCalled, isTrue);
      expect(receivedParam, equals('test'));
    });

    testWidgets('multiple observes on same command should all trigger',
        (tester) async {
      var observer1Called = false;
      var observer2Called = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final command = Command(() async {});

              command.observe(
                context,
                onSuccess: (_) {
                  observer1Called = true;
                },
              );

              command.observe(
                context,
                onSuccess: (_) {
                  observer2Called = true;
                },
              );

              return ElevatedButton(
                onPressed: command.execute,
                child: const Text('Execute'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Execute'));
      await tester.pumpAndSettle();

      expect(observer1Called, isTrue);
      expect(observer2Called, isTrue);
    });

    testWidgets('observe should receive correct BuildContext', (tester) async {
      BuildContext? capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final command = Command(() async {});

              command.observe(
                context,
                onSuccess: (ctx) {
                  capturedContext = ctx;
                },
              );

              return ElevatedButton(
                onPressed: command.execute,
                child: const Text('Execute'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Execute'));
      await tester.pumpAndSettle();

      expect(capturedContext, isNotNull);
      expect(capturedContext, isA<BuildContext>());
    });
  });
}
