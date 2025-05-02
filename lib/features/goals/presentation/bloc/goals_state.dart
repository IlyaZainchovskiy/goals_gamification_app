import 'package:equatable/equatable.dart';
import 'package:goals_gamification_app/core/models/goal.dart';

abstract class GoalsState extends Equatable {
  const GoalsState();

  @override
  List<Object?> get props => [];
}


class GoalsInitial extends GoalsState {}

class GoalsLoading extends GoalsState {}

class GoalsLoaded extends GoalsState {
  final List<Goal> allGoals;
  final List<Goal> filteredGoals;
  final GoalCategory? selectedCategory;
  final bool? filterIsCompleted;  

  const GoalsLoaded({
    required this.allGoals,
    required this.filteredGoals,
    this.selectedCategory,
    this.filterIsCompleted,
  });

  @override
  List<Object?> get props => [allGoals, filteredGoals, selectedCategory, filterIsCompleted];
}


class GoalsError extends GoalsState {
  final String message;

  const GoalsError(this.message);

  @override
  List<Object> get props => [message];
}