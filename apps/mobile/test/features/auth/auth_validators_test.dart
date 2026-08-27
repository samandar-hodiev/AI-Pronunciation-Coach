import 'package:ai_pronunciation_coach/features/auth/presentation/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidators.name', () {
    test('bo\'sh nomni rad etadi', () {
      expect(AuthValidators.name(''), isNotNull);
      expect(AuthValidators.name('   '), isNotNull);
      expect(AuthValidators.name(null), isNotNull);
    });

    test('to\'g\'ri nomni qabul qiladi', () {
      expect(AuthValidators.name('Samandar'), isNull);
    });
  });

  group('AuthValidators.email', () {
    test('bo\'sh emailni rad etadi', () {
      expect(AuthValidators.email(''), isNotNull);
    });

    test('noto\'g\'ri formatni rad etadi', () {
      for (final String email in <String>[
        'not-an-email',
        'missing@domain',
        '@example.com',
        'spaces in@example.com',
      ]) {
        expect(AuthValidators.email(email), isNotNull, reason: email);
      }
    });

    test('to\'g\'ri emailni qabul qiladi', () {
      expect(AuthValidators.email('user@example.com'), isNull);
      expect(AuthValidators.email('  user@example.com  '), isNull);
    });
  });

  group('AuthValidators.password', () {
    test('bo\'sh parolni rad etadi', () {
      expect(AuthValidators.password(''), isNotNull);
    });

    test('qisqa parolni rad etadi', () {
      expect(AuthValidators.password('short'), isNotNull);
    });

    test('yetarli uzunlikdagi parolni qabul qiladi', () {
      expect(AuthValidators.password('password123'), isNull);
    });
  });

  group('AuthValidators.confirmPassword', () {
    test('mos kelmasa rad etadi', () {
      expect(
        AuthValidators.confirmPassword('other123', 'password123'),
        isNotNull,
      );
    });

    test('mos kelsa qabul qiladi', () {
      expect(
        AuthValidators.confirmPassword('password123', 'password123'),
        isNull,
      );
    });
  });
}
