import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:plantita/screens/auth/login_screen.dart'; // Import your login screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const PlantitaApp());
}

class PlantitaApp extends StatelessWidget {
  const PlantitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plantita',
      home: LoginScreen(), // Set LoginScreen as the starting screen
    );
  }
}
