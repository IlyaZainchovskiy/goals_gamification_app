import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goals_gamification_app/features/auth/presentation/widgets/auth_button.dart';

void main() {
  testWidgets('AuthButton показує текст і викликає onPressed', (WidgetTester tester) async {
    // Arrange
    bool wasPressed = false;
    
    // Act
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
    
    // Assert
    expect(find.text('Тестова кнопка'), findsOneWidget);
    
    // Tap the button
    await tester.tap(find.byType(ElevatedButton));
    
    // Check if onPressed was called
    expect(wasPressed, isTrue);
  });
  
  testWidgets('AuthButton показує індикатор завантаження', (WidgetTester tester) async {
    // Act
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
    
    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Тестова кнопка'), findsNothing);
  });
}