import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecomesh_services/ecomesh_services.dart';
import 'screens/welcome_screen.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const ProviderScope(child: EcoMeshWebApp()));
}

class EcoMeshWebApp extends ConsumerWidget {
  const EcoMeshWebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return MaterialApp(
      title: 'EcoMesh P2P Messenger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5A27),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0D1F17),
      ),
      home: authState == AuthState.authenticated 
          ? const ChatScreen() 
          : const WelcomeScreen(),
    );
  }
}
