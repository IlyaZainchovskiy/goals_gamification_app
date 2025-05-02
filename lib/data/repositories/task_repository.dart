import 'package:goals_gamification_app/core/models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasksByGoal(String goalId);
  Future<List<Task>> getTasksByUser(String userId);
  Future<Task?> getTask(String taskId);
  Future<String> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<void> completeTask(String taskId);
  Future<List<Task>> getTodayTasks(String userId);
}