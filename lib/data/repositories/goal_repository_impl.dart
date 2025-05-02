import 'package:goals_gamification_app/core/models/goal.dart';
import 'package:goals_gamification_app/data/datasources/firebase_datasource.dart';
import 'package:goals_gamification_app/data/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final FirebaseDatasource _datasource;

  GoalRepositoryImpl(this._datasource);

  @override
  Future<List<Goal>> getGoalsByUser(String userId) async {
    final goals = await _datasource.getGoalsByUser(userId);
    
    return goals.where((goal) => !goal.isCompleted).toList();
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