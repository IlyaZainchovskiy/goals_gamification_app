import 'package:flutter/material.dart';
import 'package:goals_gamification_app/core/models/goal.dart';

abstract class GoalRepository {
  Future<void> checkAndAwardAchievements(String userId, BuildContext context);
  Future<List<Goal>> getGoalsByUser(String userId); 
  Future<List<Goal>> getAllGoalsByUser(String userId); 
  Future<List<Goal>> getCompletedGoalsByUser(String userId); 
  Future<Goal?> getGoal(String goalId);
  Future<String> createGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(String goalId);
  Future<void> completeGoal(String goalId);
  Future<List<Goal>> getGoalsByCategory(String userId, GoalCategory category);
  Future<List<Goal>> getUpcomingGoals(String userId);
}