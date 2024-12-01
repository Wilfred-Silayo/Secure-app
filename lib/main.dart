import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secure_app/controllers/developer_option_provider.dart';
import 'package:secure_app/screens/error_screen.dart';
import 'package:secure_app/screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  bool _shouldRedirectToLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check developer mode option on initialization
    ref.read(developerOptionProvider.notifier).checkDeveloperOptions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Detect when app is paused or resumed
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.resumed) {
      setState(() {
        _shouldRedirectToLogin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for changes in developer mode state
    final isDeveloperModeEnabled = ref.watch(developerOptionProvider);

    // Determine the screen to display based on the app state
    Widget screen;
    if (isDeveloperModeEnabled && !kDebugMode) {
      screen = const ErrorScreen();
    } else if (_shouldRedirectToLogin) {
      screen = const LoginScreen();
    } else {
      screen = const LoginScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(
        useMaterial3: true,
      ).copyWith(
        appBarTheme: AppBarTheme(backgroundColor: Colors.teal[200]),
      ),
      home: screen,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
