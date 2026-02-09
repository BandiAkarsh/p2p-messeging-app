import 'package:test/test.dart';
import 'package:ecomesh_services/ecomesh_services.dart';

void main() {
  group('IdentityService Tests', () {
    late IdentityService identityService;

    setUp(() {
      identityService = IdentityService();
    });

    test('generateIdentity creates valid identity', () async {
      final identity = await identityService.generateIdentity();

      expect(identity, isNotNull);
      expect(identity['userId'], hasLength(32));
      expect(identity['publicKey'], isNotEmpty);
      expect(identity['privateKey'], isNotEmpty);
      expect(identity['mnemonic'], isNotEmpty);

      // Verify mnemonic is 12 words
      final words = identity['mnemonic']!.split(' ');
      expect(words.length, equals(12));
    });

    test('generateIdentity returns unique identities', () async {
      final identity1 = await identityService.generateIdentity();
      final identity2 = await identityService.generateIdentity();

      // Each identity should be unique
      expect(identity1['userId'], isNot(equals(identity2['userId'])));
      expect(identity1['mnemonic'], isNot(equals(identity2['mnemonic'])));
    });

    test('recoverIdentity recovers from valid mnemonic', () async {
      // Generate identity first
      final originalIdentity = await identityService.generateIdentity();

      // Recover from mnemonic
      final recoveredIdentity = await identityService.recoverIdentity(
        originalIdentity['mnemonic'] as String,
      );

      expect(recoveredIdentity, isNotNull);
      expect(
        recoveredIdentity!['userId'],
        equals(originalIdentity['userId']),
      );
      expect(
        recoveredIdentity['publicKey'],
        equals(originalIdentity['publicKey']),
      );
    });

    test('recoverIdentity returns null for invalid mnemonic', () async {
      final result = await identityService.recoverIdentity(
        'invalid word list here twelve words maybe',
      );

      expect(result, isNull);
    });

    test('auditMnemonic validates standard mnemonic', () async {
      final identity = await identityService.generateIdentity();
      final audit = identityService.auditMnemonic(
        identity['mnemonic'] as String,
      );

      expect(audit['isValidLength'], isTrue);
      expect(audit['allWordsValid'], isTrue);
      expect(audit['checksumValid'], isTrue);
      expect(audit['wordCount'], equals(12));
    });

    test('formatUserId formats 32-char ID correctly', () {
      // Create a 32-character hex string
      const testId = 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6';
      final formatted = identityService.formatUserId(testId);

      // Should format as: a1b2-c3d4-e5f6-g7h8-i9j0-k1l2-m3n4-o5p6
      expect(formatted.length, equals(39)); // 32 chars + 7 dashes
    });

    test('getShortUserId shortens correctly', () {
      final short = identityService.getShortUserId('a1b2c3d4e5f6g7h8i9j0k1l2m');

      expect(short.startsWith('a1b2'), isTrue);
      expect(short.endsWith('l2m'), isTrue);
      expect(short.contains('...'), isTrue);
    });
  });
}
