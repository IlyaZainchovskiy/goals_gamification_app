import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goals_gamification_app/core/models/goal.dart';

void main() {
  group('Goal Model', () {
    test('copyWith створює нову ціль з оновленими даними', () {
      final goal = Goal(
        id: '1',
        userId: 'user1',
        title: 'Стара назва',
        createdAt: DateTime.now(),
      );
      
      final updatedGoal = goal.copyWith(
        title: 'Нова назва',
        description: 'Новий опис',
      );
      
      expect(updatedGoal.id, equals('1'));
      expect(updatedGoal.userId, equals('user1'));
      expect(updatedGoal.title, equals('Нова назва'));
      expect(updatedGoal.description, equals('Новий опис'));
    });
    
    test('priorityColor повертає правильний колір', () {
      final lowPriorityGoal = Goal(
        id: '1',
        userId: 'user1',
        title: 'Ціль',
        createdAt: DateTime.now(),
        priority: GoalPriority.low,
      );
      
      final highPriorityGoal = Goal(
        id: '2',
        userId: 'user1',
        title: 'Ціль',
        createdAt: DateTime.now(),
        priority: GoalPriority.high,
      );
      
      expect(lowPriorityGoal.priorityColor, equals(GoalPriority.low.name == 'low' ? Colors.green : null));
      expect(highPriorityGoal.priorityColor, equals(GoalPriority.high.name == 'high' ? Colors.red : null));
    });
  });
}