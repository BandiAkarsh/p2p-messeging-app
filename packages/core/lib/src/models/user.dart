import 'package:freezed_annotation/freezed_annotation.dart';          // Freezed code generation

part 'user.freezed.dart';                                              // Generated code part
part 'user.g.dart';                                                    // JSON serialization part

@freezed                                                              // Immutable class annotation
class User with _$User {                                               // Current user model
  const factory User({                                                 // Factory constructor
    required String id,                                                // Unique user ID
    required String username,                                          // Username handle
    String? displayName,                                               // Display name
    String? avatarUrl,                                                 // Avatar image URL
    required String publicKey,                                         // Public encryption key
    required DateTime createdAt,                                       // Account creation time
    @Default([]) List<String> blockedPeers,                           // Blocked peer IDs
    @Default(UserPreferences()) UserPreferences preferences,           // User settings
  }) = _User;                                                          // Private constructor

  factory User.fromJson(Map<String, dynamic> json) =>                  // JSON deserialization
      _$UserFromJson(json);                                            // Generated fromJson
}

@freezed                                                              // Settings annotation
class UserPreferences with _$UserPreferences {                         // User settings class
  const factory UserPreferences({                                      // Factory constructor
    @Default('friendly') String aiTone,                               // AI reply tone
    @Default(true) bool notifications,                                // Push notifications
    @Default(true) bool darkMode,                                     // Dark theme preference
    @Default('en') String language,                                   // Preferred language
    @Default(true) bool e2eEncryption,                                // Encryption enabled
  }) = _UserPreferences;                                               // Private constructor

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>       // JSON deserialization
      _$UserPreferencesFromJson(json);                                 // Generated fromJson
}
