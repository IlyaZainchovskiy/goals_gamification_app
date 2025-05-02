import 'package:goals_gamification_app/core/models/task.dart';
import 'package:goals_gamification_app/data/datasources/firebase_datasource.dart';
import 'package:goals_gamification_app/data/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseDatasource _datasource;

  TaskRepositoryImpl(this._datasource);

  @override
  Future<List<Task>> getTasksByGoal(String goalId) async {
    return await _datasource.getTasksByGoal(goalId);
  }

  @override
  Future<List<Task>> getTasksByUser(String userId) async {
    final goals = await _datasource.getGoalsByUser(userId);
    List<Task> allTasks = [];
    
    for (final goal in goals) {
      final tasks = await _datasource.getTasksByGoal(goal.id);
      allTasks.addAll(tasks);
    }
    
    return allTasks;
  }

  @override
  Future<Task?> getTask(String taskId) async {
    return await _datasource.getTask(taskId);
  }

  @override
  Future<String> createTask(Task task) async {
    return await _datasource.createTask(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    await _datasource.updateTask(task);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _datasource.deleteTask(taskId);
  }

  @override
  Future<void> completeTask(String taskId) async {
    final task = await _datasource.getTask(taskId);
    if (task != null) {
      await _datasource.updateTask(task.copyWith(isCompleted: true));
      
      // Оновлення прогрес цілі
      final goal = await _datasource.getGoal(task.goalId);
      if (goal != null) {
        final tasks = await _datasource.getTasksByGoal(goal.id);
        final completedTasks = tasks.where((t) => t.isCompleted).length;
        final totalTasks = tasks.length;
        final newProgress = totalTasks > 0 
            ? (completedTasks / totalTasks * 100).round() 
            : 0;
        
        await _datasource.updateGoal(
          goal.copyWith(progress: newProgress)
        );
      }
    }
  }

  @override
  Future<List<Task>> getTodayTasks(String userId) async {
    final tasks = await getTasksByUser(userId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return tasks
        .where((task) => 
            !task.isCompleted && 
            (task.deadline != null && 
             DateTime(task.deadline!.year, task.deadline!.month, task.deadline!.day)
                .isAtSameMomentAs(today)))
        .toList()
        ..sort((a, b) => a.priority.index.compareTo(b.priority.index));
  }

  
}