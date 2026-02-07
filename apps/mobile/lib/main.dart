import 'package:flutter/material.dart';                              # Flutter material widgets
import 'package:flutter_riverpod/flutter_riverpod.dart';              # Riverpod widgets
import 'screens/chat_screen.dart';                                    # Chat screen import

void main() {                                                         # Application entry point
  WidgetsFlutterBinding.ensureInitialized();                          # Initialize Flutter bindings
  runApp(const ProviderScope(child: EcoMeshApp()));                   # Run app with Riverpod scope
}

class EcoMeshApp extends StatelessWidget {                            # Root app widget
  const EcoMeshApp({super.key});                                      # Constructor

  @override
  Widget build(BuildContext context) {                                # Build method
    return MaterialApp(                                               # Material app wrapper
      title: 'EcoMesh',                                               # App title
      debugShowCheckedModeBanner: false,                              # Hide debug banner
      theme: ThemeData(                                               # Light theme
        colorScheme: ColorScheme.fromSeed(                            # Generate color scheme
          seedColor: const Color(0xFF2D5A27),                         # Green seed color
          brightness: Brightness.dark,                                # Dark mode (green code)
        ),
        useMaterial3: true,                                           # Material 3 design
        fontFamily: 'Roboto',                                         # Default font
      ),
      home: const ChatScreen(),                                       # Initial screen
    );
  }
}
