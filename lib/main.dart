import 'package:bafna_track/models/flat_model.dart';
import 'package:bafna_track/screens/admin_panel_screen.dart';
import 'package:bafna_track/screens/flat_details_screen.dart';
import 'package:bafna_track/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dyxbpilvjuwdocjzxxjy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR5eGJwaWx2anV3ZG9janp4eGp5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0MjY5ODcsImV4cCI6MjA2OTAwMjk4N30.W-LQtX7erCTgZf4WH8JYo-BeS8iU-zi7HEL6W9nPILg',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BafnaTrack App',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
      routes: {'/adminPanel': (context) => const AdminPanelScreen()},
      onGenerateRoute: (settings) {
        if (settings.name == '/flatDetail') {
          final flat = settings.arguments as Flat?;
          if (flat != null) {
            return MaterialPageRoute(builder: (context) => FlatDetailsScreen(initialFlat: flat));
          }
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}