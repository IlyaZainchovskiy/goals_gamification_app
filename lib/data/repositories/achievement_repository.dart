import 'package:goals_gamification_app/core/models/achievement.dart';

abstract class AchievementRepository {
  Future<List<Achievement>> getAchievementsByUser(String userId);
  Future<void> checkAndAwardAchievements(String userId);
  Future<Achievement?> getAchievementById(String achievementId);
  Future<List<Achievement>> getAllAchievements();
}