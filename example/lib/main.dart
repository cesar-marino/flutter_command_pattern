import 'package:flutter/material.dart';
import 'package:flutter_command_pattern/flutter_command_pattern.dart';

void main() {
  // Setup global logging pipeline
  CommandPipelineRegistry.addPipeline((context, next) async {
    debugPrint('🚀 Command started: ${context.command.runtimeType}');
    final stopwatch = Stopwatch()..start();

    await next();

    stopwatch.stop();
    debugPrint(
      '✅ Command finished: ${context.command.runtimeType} '
      'in ${stopwatch.elapsedMilliseconds}ms',
    );
  });

  // Setup global error observer
  CommandObserverRegistry.addObserver((context) {
    if (context.state is CommandFailure) {
      debugPrint('❌ Command failed: ${context.error}');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Command Pattern Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Simple login command
  late final _loginCommand = Command(_performLogin);

  // Command with parameters example
  late final _fetchUserCommand = CommandWithParams<String>(_fetchUser);

  Future<void> _performLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      throw Exception('Email and password are required');
    }

    if (_emailController.text != 'test@example.com' ||
        _passwordController.text != 'password') {
      throw Exception('Invalid credentials');
    }

    // Success!
  }

  Future<void> _fetchUser(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Fetched user: $userId');
  }

  @override
  void initState() {
    super.initState();

    // Observe login command
    _loginCommand.observe(
      context,
      onLoading: _showLoadingDialog,
      onSuccess: _onLoginSuccess,
      onFailure: _onLoginFailure,
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  void _onLoginSuccess(BuildContext context) {
    Navigator.of(context).pop(); // Close loading dialog

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login successful!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to home or fetch user data
    _fetchUserCommand.execute('user123');
  }

  void _onLoginFailure(BuildContext context, Object error) {
    Navigator.of(context).pop(); // Close loading dialog

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login failed: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Command Pattern Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'test@example.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: _loginCommand,
              builder: (context, _) {
                return ElevatedButton(
                  onPressed:
                      _loginCommand.isRunning ? null : _loginCommand.execute,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(
                    _loginCommand.isRunning ? 'Loading...' : 'Login',
                  ),
                );
              },
            ),
            if (_loginCommand.hasError) ...[
              const SizedBox(height: 16),
              Text(
                'Error: ${_loginCommand.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _loginCommand.dispose();
    _fetchUserCommand.dispose();
    super.dispose();
  }
}
