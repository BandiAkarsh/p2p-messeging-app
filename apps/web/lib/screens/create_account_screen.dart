import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecomesh_services/ecomesh_services.dart';
import 'package:ecomesh_adapters/ecomesh_adapters.dart';
import 'package:ecomesh_core/ecomesh_core.dart';
import 'backup_phrase_screen.dart';

/// Create Account Screen
/// Generates decentralized identity with 12-word mnemonic
class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _createAccount() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final identityService = ref.read(identityServiceProvider);
      final storage = ref.read(storageProvider);
      
      // Generate identity
      final identity = await identityService.generateIdentity();
      
      // Save identity securely
      await (storage as SecureStorageAdapter).saveUserIdentity(identity);
      
      // Create user object
      final user = User(
        id: identity['userId']!,
        username: 'user_${identity['userId']!.substring(0, 8)}',
        displayName: 'Anonymous User',
        publicKey: identity['publicKey']!,
        createdAt: DateTime.now(),
      );
      
      // Update auth state
      ref.read(currentUserProvider.notifier).setUser(user);
      
      // Navigate to backup phrase screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BackupPhraseScreen(
              mnemonic: identity['mnemonic']!,
              userId: identity['userId']!,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to create account: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D1F17),
              const Color(0xFF1A3A2B),
              const Color(0xFF0D1F17),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Features list
                _FeatureItem(
                  icon: Icons.shield,
                  title: 'Decentralized Identity',
                  description: 'Your identity is generated locally on your device',
                ),
                
                const SizedBox(height: 20),
                
                _FeatureItem(
                  icon: Icons.key,
                  title: '12-Word Recovery Phrase',
                  description: 'Write it down to recover your account anywhere',
                ),
                
                const SizedBox(height: 20),
                
                _FeatureItem(
                  icon: Icons.lock,
                  title: 'End-to-End Encryption',
                  description: 'Only you and your contacts can read messages',
                ),
                
                const Spacer(),
                
                // Error message
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                if (_error != null) const SizedBox(height: 16),
                
                // Create button
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
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D5A27).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : _createAccount,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text(
                                'Create My Account',
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

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D5A27).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
