import 'package:equatable/equatable.dart';
import 'package:goals_gamification_app/core/models/goal.dart';

abstract class GoalsEvent extends Equatable {
  const GoalsEvent();

  @override
  List<Object?> get props => [];
}

class FilterGoalsByStatus extends GoalsEvent {
  final bool? isCompleted;

  const FilterGoalsByStatus(this.isCompleted);

  @override
  List<Object?> get props => [isCompleted];
}

class LoadGoals extends GoalsEvent {
  final String userId;

  const LoadGoals(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddGoal extends GoalsEvent {
  final Goal goal;

  const AddGoal(this.goal);

  @override
  List<Object> get props => [goal];
}

class UpdateGoal extends GoalsEvent {
  final Goal goal;

  const UpdateGoal(this.goal);

  @override
  List<Object> get props => [goal];
}

class DeleteGoal extends GoalsEvent {
  final String goalId;

  const DeleteGoal(this.goalId);

  @override
  List<Object> get props => [goalId];
}

class CompleteGoal extends GoalsEvent {
  final String goalId;

  const CompleteGoal(this.goalId);

  @override
  List<Object> get props => [goalId];
}

class FilterGoalsByCategory extends GoalsEvent {
  final GoalCategory? category;

  const FilterGoalsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}