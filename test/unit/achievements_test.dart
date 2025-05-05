import 'package:flutter_test/flutter_test.dart';
import 'package:goals_gamification_app/core/models/achievement.dart';

void main() {
  test('Achievement.predefinedAchievements містить правильні досягнення', () {
    final achievements = Achievement.predefinedAchievements;
    
    expect(achievements, isNotEmpty);
    expect(achievements.length, greaterThanOrEqualTo(4));
    
    expect(
      achievements.any((a) => a.id == 'first-success'), 
      isTrue
    );
    
    expect(
      achievements.any((a) => a.id == 'triple-daily'), 
      isTrue
    );
    
    expect(
      achievements.any((a) => a.type == AchievementType.completeTasks), 
      isTrue
    );
  });
}