import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init(); // sets up local Hive database, seeds chapters
  runApp(const LoveJourneyApp());
}

class LoveJourneyApp extends StatelessWidget {
  const LoveJourneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Love Journey',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFF0D0620),
      ),
      home: const HomeScreen(),
    );
  }
}
