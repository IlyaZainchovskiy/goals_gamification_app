import 'package:equatable/equatable.dart';
import 'package:goals_gamification_app/core/models/goal.dart';
import 'package:goals_gamification_app/core/models/task.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<Task> allTasks;
  final List<Task> filteredTasks;
  final Goal? relatedGoal;
  final bool? filterIsCompleted;

  const TasksLoaded({
    required this.allTasks,
    required this.filteredTasks,
    this.relatedGoal,
    this.filterIsCompleted,
  });

  @override
  List<Object?> get props => [allTasks, filteredTasks, relatedGoal, filterIsCompleted];
}

class TasksError extends TasksState {
  final String message;

  const TasksError(this.message);

  @override
  List<Object> get props => [message];
}