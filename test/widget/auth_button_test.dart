import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goals_gamification_app/features/auth/presentation/widgets/auth_button.dart';

void main() {
  testWidgets('AuthButton показує текст і викликає onPressed', (WidgetTester tester) async {
    bool wasPressed = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthButton(
            text: 'Тестова кнопка',
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      ),
    );
    
    expect(find.text('Тестова кнопка'), findsOneWidget);
    
    await tester.tap(find.byType(ElevatedButton));
    
    expect(wasPressed, isTrue);
  });
  
  testWidgets('AuthButton показує індикатор завантаження', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthButton(
            text: 'Тестова кнопка',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      ),
    );
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Тестова кнопка'), findsNothing);
  });
}