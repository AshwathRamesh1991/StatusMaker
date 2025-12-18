import 'dart:async'; // Added for TimeoutException
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:status_maker/services/data_service.dart';
import 'services/favorites_service.dart';
import 'services/query_service.dart';
import 'screens/home_screen.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(const AppBootstrap());
    },
    (error, stack) {
      debugPrint("FATAL ERROR CAUGHT: $error");
      debugPrint(stack.toString());
    },
  );
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<FavoritesService> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<FavoritesService> _init() async {
    try {
      // Create a future that runs the initialization logic
      final initTask = Future(() async {
        final favoritesService = await FavoritesService.init();
        await DataService.loadData(); // Load JSON data
        QueryService().initialize();
        return favoritesService;
      });

      // Race against a timeout
      return await initTask.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            "App initialization took too long. Check internet or assets.",
          );
        },
      );
    } catch (e) {
      debugPrint("Initialization error: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FavoritesService>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a simple loading screen while initializing
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: const Color(0xFF6C63FF),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 20),
                    Text(
                      'Loading StatusMaker...',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          // Show error screen if initialization fails
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Colors.red.shade900,
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Failed to load app',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _initFuture = _init();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Initialization successful
        return MultiProvider(
          providers: [Provider<FavoritesService>.value(value: snapshot.data!)],
          child: const StatusMakerApp(),
        );
      },
    );
  }
}

class StatusMakerApp extends StatelessWidget {
  const StatusMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StatusMaker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF), // Trendy Violet/Blue
          brightness:
              Brightness.dark, // Dark mode by default for media consumption
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      home: const HomeScreen(),
    );
  }
}
