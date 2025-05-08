import 'package:flutter/material.dart';
import 'package:goals_gamification_app/core/models/achievement.dart';
import 'package:goals_gamification_app/core/models/task.dart';
import 'package:goals_gamification_app/core/services/notification_service.dart';
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
Future<void> checkAndAwardAchievements(String userId, BuildContext context) async {
  try {
    print("Перевірка досягнень для користувача: $userId");
    
    final user = await _datasource.getUser(userId);
    if (user == null) {
      print("Користувача не знайдено");
      return;
    }
    
    final userAchievements = await _datasource.getUserAchievements(userId);
    print("Поточні досягнення користувача: $userAchievements");
    
    final goals = await _datasource.getGoalsByUser(userId);
    print("Знайдено ${goals.length} цілей");
    
    int completedTaskCount = 0;
    int todayTaskCount = 0;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    List<Task> allTasks = [];
    for (final goal in goals) {
      final tasks = await _datasource.getTasksByGoal(goal.id);
      allTasks.addAll(tasks);
    }
    
    completedTaskCount = allTasks.where((task) => task.isCompleted).length;
    
    todayTaskCount = allTasks.where((task) => 
      task.isCompleted && 
      DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day)
          .isAtSameMomentAs(today)
    ).length;
    
    print("Завершених завдань всього: $completedTaskCount");
    print("Завершених завдань сьогодні: $todayTaskCount");
    
    // Перевірка досягнень
    for (final achievement in Achievement.predefinedAchievements) {
      if (!userAchievements.contains(achievement.id)) {
        bool awarded = false;
        
        print("Перевірка досягнення: ${achievement.title} (${achievement.id}), тип: ${achievement.type}");
        
        switch (achievement.type) {
          case AchievementType.completeTasks:
            print("  Порівнюємо $completedTaskCount >= ${achievement.threshold}");
            if (completedTaskCount >= achievement.threshold) {
              awarded = true;
            }
            break;
          case AchievementType.createGoals:
            print("  Порівнюємо ${goals.length} >= ${achievement.threshold}");
            if (goals.length >= achievement.threshold) {
              awarded = true;
            }
            break;
          case AchievementType.dailyStreak:
            print("  Порівнюємо $todayTaskCount >= ${achievement.threshold}");
            if (todayTaskCount >= achievement.threshold) {
              awarded = true;
            }
            break;
          default:
            break;
        }
        
        if (awarded) {
          print("Нагороджено досягненням: ${achievement.title}");
          
          await _userRepository.addAchievement(userId, achievement.id);
          
          await _userRepository.addXp(userId, achievement.xpReward);
          
          if (context.mounted) {
            NotificationService.showAchievementNotification(context, achievement);
            NotificationService.showAchievementDialog(context, achievement);
          }
        } else {
          print(" Не виконано умову для досягнення");
        }
      }
    }
  } catch (e) {
    print("Помилка при перевірці досягнень: $e");
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