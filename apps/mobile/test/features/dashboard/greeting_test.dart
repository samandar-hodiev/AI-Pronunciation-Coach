import 'package:ai_pronunciation_coach/features/dashboard/presentation/widgets/greeting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('greetingFor', () {
    test('ertalab, tushdan keyin va kechqurun matnini beradi', () {
      expect(
        greetingFor(DateTime(2026, 1, 1, 8), 'Alex'),
        'Good morning, Alex',
      );
      expect(
        greetingFor(DateTime(2026, 1, 1, 14), 'Alex'),
        'Good afternoon, Alex',
      );
      expect(
        greetingFor(DateTime(2026, 1, 1, 20), 'Alex'),
        'Good evening, Alex',
      );
    });

    test('erta tong va yarim tun kechqurun deb hisoblanadi', () {
      expect(
        greetingFor(DateTime(2026, 1, 1, 3), 'Alex'),
        'Good evening, Alex',
      );
      expect(
        greetingFor(DateTime(2026, 1, 1, 23), 'Alex'),
        'Good evening, Alex',
      );
    });

    test('ism bo\'lmasa umumiy salomlashish ishlatiladi', () {
      // Vaqtdan qat'i nazar, ismsiz jumla g'alati o'qilmasligi kerak.
      expect(greetingFor(DateTime(2026, 1, 1, 8), null), 'Welcome back');
      expect(greetingFor(DateTime(2026, 1, 1, 8), ''), 'Welcome back');
      expect(greetingFor(DateTime(2026, 1, 1, 8), '   '), 'Welcome back');
    });
  });

  group('initialsFor', () {
    test('bir va ikki so\'zli ismdan bosh harf oladi', () {
      expect(initialsFor('Samandar'), 'S');
      expect(initialsFor('Samandar Hodiev'), 'SH');
      expect(initialsFor('  ali  vali  '), 'AV');
    });

    test('ism bo\'lmasa o\'rin egallovchi qaytaradi', () {
      expect(initialsFor(null), '?');
      expect(initialsFor(''), '?');
    });
  });
}
