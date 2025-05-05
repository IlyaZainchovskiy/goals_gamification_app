import 'package:flutter_test/flutter_test.dart';
import 'package:goals_gamification_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('повертає помилку для порожнього email', () {
        expect(Validators.validateEmail(''), isNotNull);
      });
      
      test('повертає помилку для неправильного email', () {
        expect(Validators.validateEmail('not-an-email'), isNotNull);
      });
      
      test('повертає null для правильного email', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
      });
    });
    
    group('validatePassword', () {
      test('повертає помилку для порожнього пароля', () {
        expect(Validators.validatePassword(''), isNotNull);
      });
      
      test('повертає помилку для короткого пароля', () {
        expect(Validators.validatePassword('12345'), isNotNull);
      });
      
      test('повертає null для правильного пароля', () {
        expect(Validators.validatePassword('password123'), isNull);
      });
    });
  });
}