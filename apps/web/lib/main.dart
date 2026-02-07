import 'package:flutter/material.dart'; // Flutter material widgets
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod
import 'screens/chat_screen.dart'; // Chat screen

void main() { // Web entry point
  runApp(const ProviderScope(child: EcoMeshWebApp())); // Run with Riverpod
}

class EcoMeshWebApp extends StatelessWidget { // Web app widget
  const EcoMeshWebApp({super.key}); // Constructor

  @override
  Widget build(BuildContext context) { // Build UI
    return MaterialApp( // Material app
      title: 'EcoMesh Web', // App title
      debugShowCheckedModeBanner: false, // Hide debug banner
      theme: ThemeData( // Theme
        colorScheme: ColorScheme.fromSeed( // Color scheme
          seedColor: const Color(0xFF2D5A27), // Green seed
          brightness: Brightness.dark, // Dark mode
        ),
        useMaterial3: true, // Material 3
      ),
      home: const ChatScreen(), // Home screen
    );
  }
}
