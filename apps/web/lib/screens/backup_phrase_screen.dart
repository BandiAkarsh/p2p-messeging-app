import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chat_screen.dart';

/// Backup Phrase Screen
/// Shows the 12-word recovery phrase after account creation
class BackupPhraseScreen extends StatelessWidget {
  final String mnemonic;
  final String userId;

  const BackupPhraseScreen({
    super.key,
    required this.mnemonic,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final words = mnemonic.split(' ');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0xFF0D1F17),
              Color(0xFF1A3A2B),
              Color(0xFF0D1F17),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Warning icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 40,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Save Your Recovery Phrase',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                // Warning text
                Text(
                  'Write these 12 words down in order. They are the only way to recover your account. Never share them with anyone!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 32),

                // Mnemonic grid
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Copy button
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: mnemonic));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, color: Colors.white70),
                          tooltip: 'Copy phrase',
                        ),
                      ),

                      // Words grid
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(12, (index) {
                          return Container(
                            width:
                                (MediaQuery.of(context).size.width - 104) / 3,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${index + 1}.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    words[index],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Continue button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2D5A27).withValues(alpha: 0.8),
                        const Color(0xFF1E3D1A).withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text(
                          'I\'ve Written It Down',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
