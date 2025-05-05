import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goals_gamification_app/core/models/achievement.dart';
import 'package:goals_gamification_app/features/profile/presentation/screens/profile_screen.dart';

void main() {
  testWidgets('AchievementCard відображає розблоковане досягнення', (WidgetTester tester) async {
    final achievement = Achievement(
      id: 'test-achievement',
      title: 'Тестове досягнення',
      description: 'Опис тестового досягнення',
      xpReward: 15,
      iconName: 'trophy',
      type: AchievementType.completeTasks,
      threshold: 5,
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AchievementCard(
            achievement: achievement,
            isUnlocked: true,
          ),
        ),
      ),
    );
    
    expect(find.text('Тестове досягнення'), findsOneWidget);
    expect(find.text('Опис тестового досягнення'), findsOneWidget);
    expect(find.text('+15 XP'), findsOneWidget);
    
    expect(find.text('Не відкрито'), findsNothing);
  });
  
  testWidgets('AchievementCard відображає заблоковане досягнення', (WidgetTester tester) async {
    final achievement = Achievement(
      id: 'test-achievement',
      title: 'Тестове досягнення',
      description: 'Опис тестового досягнення',
      xpReward: 15,
      iconName: 'trophy',
      type: AchievementType.completeTasks,
      threshold: 5,
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AchievementCard(
            achievement: achievement,
            isUnlocked: false,
          ),
        ),
      ),
    );
    
    expect(find.text('Тестове досягнення'), findsOneWidget);
    expect(find.text('Опис тестового досягнення'), findsOneWidget);
    expect(find.text('Не відкрито'), findsOneWidget);
    
    expect(find.text('+15 XP'), findsNothing);
  });
}