import 'package:goals_gamification_app/core/models/achievement.dart';
import 'package:goals_gamification_app/data/datasources/firebase_datasource.dart';
import 'package:goals_gamification_app/data/repositories/achievement_repository.dart';
import 'package:goals_gamification_app/data/repositories/user_repository.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  final FirebaseDatasource _datasource;
  final UserRepository _userRepository;

  AchievementRepositoryImpl(this._datasource, this._userRepository);

  @override
  Future<List<Achievement>> getAchievementsByUser(String userId) async {
    final userAchievementIds = await _datasource.getUserAchievements(userId);
    final allAchievements = Achievement.predefinedAchievements;
    
    return allAchievements
        .where((achievement) => userAchievementIds.contains(achievement.id))
        .toList();
  }

  @override
  Future<void> checkAndAwardAchievements(String userId) async {
    final user = await _datasource.getUser(userId);
    if (user == null) return;
    
    final userAchievements = await _datasource.getUserAchievements(userId);
    
    // Отримання всіх завдання користувача
    final goals = await _datasource.getGoalsByUser(userId);
    int taskCount = 0;
    int todayTaskCount = 0;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Підрахунок кількість завдань і завдань сьогодні
    for (final goal in goals) {
      final tasks = await _datasource.getTasksByGoal(goal.id);
      taskCount += tasks.where((task) => task.isCompleted).length;
      
      todayTaskCount += tasks.where((task) => 
        task.isCompleted && 
        DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day)
            .isAtSameMomentAs(today)
      ).length;
    }
    
    // Перевірка досягнення
    for (final achievement in Achievement.predefinedAchievements) {
      if (!userAchievements.contains(achievement.id)) {
        bool awarded = false;
        
        switch (achievement.type) {
          case AchievementType.completeTasks:
            if (taskCount >= achievement.threshold) {
              awarded = true;
            }
            break;
          case AchievementType.createGoals:
            if (goals.length >= achievement.threshold) {
              awarded = true;
            }
            break;
          case AchievementType.dailyStreak:
            if (todayTaskCount >= achievement.threshold) {
              awarded = true;
            }
            break;
          default:
            break;
        }
        
        if (awarded) {
          await _userRepository.addAchievement(userId, achievement.id);
          await _userRepository.addXp(userId, achievement.xpReward);
        }
      }
    }
  }

@override
Future<Achievement?> getAchievementById(String achievementId) {
  try {
    final achievement = Achievement.predefinedAchievements
        .firstWhere((a) => a.id == achievementId);
    return Future.value(achievement);
  } catch (e) {
    return Future.value(null);
  }
}

  @override
  Future<List<Achievement>> getAllAchievements() {
    return Future.value(Achievement.predefinedAchievements);
  }
}