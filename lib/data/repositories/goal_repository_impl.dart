import 'package:flutter/material.dart';
import 'package:goals_gamification_app/core/models/achievement.dart';
import 'package:goals_gamification_app/core/models/goal.dart';
import 'package:goals_gamification_app/core/services/notification_service.dart';
import 'package:goals_gamification_app/data/datasources/firebase_datasource.dart';
import 'package:goals_gamification_app/data/repositories/goal_repository.dart';
import 'package:goals_gamification_app/data/repositories/user_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final FirebaseDatasource _datasource;
  final UserRepository _userRepository;

  GoalRepositoryImpl(this._datasource, this._userRepository);

  @override
  Future<List<Goal>> getGoalsByUser(String userId) async {
    final goals = await _datasource.getGoalsByUser(userId);
    
    return goals.where((goal) => !goal.isCompleted).toList();
  }
  @override
  Future<void> checkAndAwardAchievements(String userId, BuildContext context) async {
  final user = await _datasource.getUser(userId);
  if (user == null) return;
  
  final userAchievements = await _datasource.getUserAchievements(userId);
  
  // Отримання ВСІХ цілей користувача, включно з завершеними
  final goals = await _datasource.getGoalsByUser(userId);
  int taskCount = 0;
  int todayTaskCount = 0;
  
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // Підрахунок завдань
  for (final goal in goals) {
    final tasks = await _datasource.getTasksByGoal(goal.id);
    taskCount += tasks.where((task) => task.isCompleted).length;
    
    todayTaskCount += tasks.where((task) => 
      task.isCompleted && 
      DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day)
          .isAtSameMomentAs(today)
    ).length;
  }
  print('Загальна кількість виконаних завдань: $taskCount');
  print('Кількість виконаних завдань сьогодні: $todayTaskCount');
  
  for (final achievement in Achievement.predefinedAchievements) {
    if (!userAchievements.contains(achievement.id)) {
      bool awarded = false;
      
      switch (achievement.type) {
        case AchievementType.completeTasks:
          print('Перевірка досягнення "${achievement.title}": поріг=${achievement.threshold}, поточний=$taskCount');
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
        print('Отримано досягнення: ${achievement.title}');
        await _userRepository.addAchievement(userId, achievement.id);
        await _userRepository.addXp(userId, achievement.xpReward);
        
        if (context.mounted) {
          NotificationService.showAchievementNotification(context, achievement);
        }
      }
    }
  }
}

  @override
  Future<List<Goal>> getAllGoalsByUser(String userId) async {
    return await _datasource.getGoalsByUser(userId);
  }

  @override
  Future<List<Goal>> getCompletedGoalsByUser(String userId) async {
    final goals = await _datasource.getGoalsByUser(userId);
    return goals.where((goal) => goal.isCompleted).toList();
  }



  @override
  Future<Goal?> getGoal(String goalId) async {
    return await _datasource.getGoal(goalId);
  }

  @override
  Future<String> createGoal(Goal goal) async {
    return await _datasource.createGoal(goal);
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    await _datasource.updateGoal(goal);
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await _datasource.deleteGoal(goalId);
  }

  @override
  Future<void> completeGoal(String goalId) async {
    final goal = await _datasource.getGoal(goalId);
    if (goal != null) {
      await _datasource.updateGoal(goal.copyWith(
        isCompleted: true,
        progress: 100,
      ));
    }
  }

  @override
  Future<List<Goal>> getGoalsByCategory(String userId, GoalCategory category) async {
    final goals = await _datasource.getGoalsByUser(userId);
    return goals.where((goal) => goal.category == category).toList();
  }

  @override
  Future<List<Goal>> getUpcomingGoals(String userId) async {
    final goals = await _datasource.getGoalsByUser(userId);
    final now = DateTime.now();
    
    return goals
        .where((goal) => 
            !goal.isCompleted && 
            goal.deadline != null && 
            goal.deadline!.isAfter(now))
        .toList()
        ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
  }
}