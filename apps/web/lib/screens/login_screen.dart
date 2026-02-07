import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecomesh_services/ecomesh_services.dart';
import 'package:ecomesh_adapters/ecomesh_adapters.dart';
import 'package:ecomesh_core/ecomesh_core.dart';
import 'chat_screen.dart';

/// Login Screen
/// Recover account using 12-word mnemonic phrase
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final List<TextEditingController> _wordControllers = 
      List.generate(12, (_) => TextEditingController());
  bool _isLoading = false;
  String? _error;

  Future<void> _recoverAccount() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Collect words
      final words = _wordControllers.map((c) => c.text.trim().toLowerCase()).toList();
      
      // Validate all words filled
      if (words.any((w) => w.isEmpty)) {
        setState(() {
          _error = 'Please enter all 12 words';
        });
        return;
      }
      
      final mnemonic = words.join(' ');
      
      final identityService = ref.read(identityServiceProvider);
      final storage = ref.read(storageProvider);
      
      // Recover identity
      final identity = await identityService.recoverIdentity(mnemonic);
      
      if (identity == null) {
        setState(() {
          _error = 'Invalid recovery phrase. Please check your words.';
        });
        return;
      }
      
      // Save recovered identity
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
      
      // Navigate to chat
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to recover account: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _wordControllers) {
      controller.dispose();
    }
    super.dispose();
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                  'Recover Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Enter your 12-word recovery phrase',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Mnemonic grid
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                alignment: Alignment.center,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _wordControllers[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                  textInputAction: index < 11 
                                      ? TextInputAction.next 
                                      : TextInputAction.done,
                                  onSubmitted: (_) {
                                    if (index < 11) {
                                      FocusScope.of(context).nextFocus();
                                    } else {
                                      _recoverAccount();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
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
                
                // Recover button
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
                      onTap: _isLoading ? null : _recoverAccount,
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
                                'Recover Account',
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
