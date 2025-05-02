import 'package:equatable/equatable.dart';
import 'package:goals_gamification_app/core/models/goal.dart';
import 'package:goals_gamification_app/core/models/task.dart';
import 'package:goals_gamification_app/core/models/user.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final UserModel user;
  final List<Task> todayTasks;
  final List<Goal> upcomingGoals;
  final int completedTasksToday;

  const DashboardLoaded({
    required this.user,
    required this.todayTasks,
    required this.upcomingGoals,
    required this.completedTasksToday,
  });

  @override
  List<Object> get props => [user, todayTasks, upcomingGoals, completedTasksToday];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}