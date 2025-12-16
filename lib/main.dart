import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:status_maker/services/data_service.dart';
import 'services/favorites_service.dart';
import 'services/query_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final favoritesService = await FavoritesService.init();
  await DataService.loadData(); // Load JSON data
  QueryService().initialize();

  runApp(
    MultiProvider(
      providers: [Provider<FavoritesService>.value(value: favoritesService)],
      child: const StatusMakerApp(),
    ),
  );
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
