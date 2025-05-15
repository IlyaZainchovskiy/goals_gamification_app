import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goals_gamification_app/core/models/goal.dart';
import 'package:goals_gamification_app/data/repositories/goal_repository.dart';
import 'package:goals_gamification_app/features/goals/presentation/bloc/goals_event.dart';
import 'package:goals_gamification_app/features/goals/presentation/bloc/goals_state.dart';

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  final GoalRepository _goalRepository;

  GoalsBloc({
    required GoalRepository goalRepository,
  })  : _goalRepository = goalRepository,
        super(GoalsInitial()) {
    on<LoadGoals>(_onLoadGoals);
    on<AddGoal>(_onAddGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<DeleteGoal>(_onDeleteGoal);
    on<CompleteGoal>(_onCompleteGoal);
    on<FilterGoalsByCategory>(_onFilterGoalsByCategory);
    on<FilterGoalsByStatus>(_onFilterGoalsByStatus);
  }

Future<void> _onLoadGoals(
  LoadGoals event,
  Emitter<GoalsState> emit,
) async {
  emit(GoalsLoading());
  try {
    final goals = await _goalRepository.getAllGoalsByUser(event.userId);
    final filteredGoals = goals.where((goal) => !goal.isCompleted).toList();
    emit(GoalsLoaded(
      allGoals: goals, 
      filteredGoals: filteredGoals,
      filterIsCompleted: false  
    ));
  } catch (e) {
    emit(GoalsError(e.toString()));
  }
}

  Future<void> _onAddGoal(
    AddGoal event,
    Emitter<GoalsState> emit,
  ) async {
    final currentState = state;
    if (currentState is GoalsLoaded) {
      try {
        await _goalRepository.createGoal(event.goal);
        final updatedGoals = await _goalRepository.getGoalsByUser(event.goal.userId);
        
        List<Goal> filteredGoals = updatedGoals;
        if (currentState.selectedCategory != null) {
          filteredGoals = updatedGoals
              .where((goal) => goal.category == currentState.selectedCategory)
              .toList();
        }
        
        emit(GoalsLoaded(
          allGoals: updatedGoals,
          filteredGoals: filteredGoals,
          selectedCategory: currentState.selectedCategory,
        ));
      } catch (e) {
        emit(GoalsError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateGoal(
    UpdateGoal event,
    Emitter<GoalsState> emit,
  ) async {
    final currentState = state;
    if (currentState is GoalsLoaded) {
      try {
        await _goalRepository.updateGoal(event.goal);
        final updatedGoals = await _goalRepository.getGoalsByUser(event.goal.userId);
        
        List<Goal> filteredGoals = updatedGoals;
        if (currentState.selectedCategory != null) {
          filteredGoals = updatedGoals
              .where((goal) => goal.category == currentState.selectedCategory)
              .toList();
        }
        
        emit(GoalsLoaded(
          allGoals: updatedGoals,
          filteredGoals: filteredGoals,
          selectedCategory: currentState.selectedCategory,
        ));
      } catch (e) {
        emit(GoalsError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteGoal(
    DeleteGoal event,
    Emitter<GoalsState> emit,
  ) async {
    final currentState = state;
    if (currentState is GoalsLoaded) {
      try {
        await _goalRepository.deleteGoal(event.goalId);
        
        final updatedGoals = currentState.allGoals
            .where((goal) => goal.id != event.goalId)
            .toList();
            
        List<Goal> filteredGoals = updatedGoals;
        if (currentState.selectedCategory != null) {
          filteredGoals = updatedGoals
              .where((goal) => goal.category == currentState.selectedCategory)
              .toList();
        }
        
        emit(GoalsLoaded(
          allGoals: updatedGoals,
          filteredGoals: filteredGoals,
          selectedCategory: currentState.selectedCategory,
        ));
      } catch (e) {
        emit(GoalsError(e.toString()));
      }
    }
  }

Future<void> _onCompleteGoal(
  CompleteGoal event,
  Emitter<GoalsState> emit,
) async {
  final currentState = state;
  if (currentState is GoalsLoaded) {
    try {
      await _goalRepository.completeGoal(event.goalId);
      
      final goalIndex = currentState.allGoals
          .indexWhere((goal) => goal.id == event.goalId);
          
      if (goalIndex != -1) {
        final updatedGoal = currentState.allGoals[goalIndex]
            .copyWith(isCompleted: true, progress: 100);
            
        final updatedGoals = List<Goal>.from(currentState.allGoals);
        updatedGoals[goalIndex] = updatedGoal;
        
        List<Goal> filteredGoals = updatedGoals;
        if (currentState.filterIsCompleted != null) {
          filteredGoals = updatedGoals
              .where((goal) => goal.isCompleted == currentState.filterIsCompleted)
              .toList();
        }
        
        if (currentState.selectedCategory != null) {
          filteredGoals = filteredGoals
              .where((goal) => goal.category == currentState.selectedCategory)
              .toList();
        }
        
        emit(GoalsLoaded(
          allGoals: updatedGoals,
          filteredGoals: filteredGoals,
          selectedCategory: currentState.selectedCategory,
          filterIsCompleted: currentState.filterIsCompleted,
        ));
        
        // додати XP користувачу за виконання цілі
        //  20 XP за кожну завершену ціль
        // await _userRepository.addXp(userId, 20);
      }
    } catch (e) {
      emit(GoalsError(e.toString()));
    }
  }
}
  void _onFilterGoalsByStatus(
  FilterGoalsByStatus event,
  Emitter<GoalsState> emit,
) {
  final currentState = state;
  if (currentState is GoalsLoaded) {
    if (event.isCompleted == null) {
      List<Goal> filteredGoals = currentState.allGoals;
      if (currentState.selectedCategory != null) {
        filteredGoals = filteredGoals
            .where((goal) => goal.category == currentState.selectedCategory)
            .toList();
      }
      
      emit(GoalsLoaded(
        allGoals: currentState.allGoals,
        filteredGoals: filteredGoals,
        selectedCategory: currentState.selectedCategory,
        filterIsCompleted: null,
      ));
    } else {
      List<Goal> filteredGoals = currentState.allGoals
          .where((goal) => goal.isCompleted == event.isCompleted)
          .toList();
      if (currentState.selectedCategory != null) {
        filteredGoals = filteredGoals
            .where((goal) => goal.category == currentState.selectedCategory)
            .toList();
      }
      
      emit(GoalsLoaded(
        allGoals: currentState.allGoals,
        filteredGoals: filteredGoals,
        selectedCategory: currentState.selectedCategory,
        filterIsCompleted: event.isCompleted,
      ));
    }
  }
}

  void _onFilterGoalsByCategory(
    FilterGoalsByCategory event,
    Emitter<GoalsState> emit,
  ) {
    final currentState = state;
    if (currentState is GoalsLoaded) {
      if (event.category == null) {
        emit(GoalsLoaded(
          allGoals: currentState.allGoals,
          filteredGoals: currentState.allGoals,
          selectedCategory: null,
        ));
      } else {
        final filteredGoals = currentState.allGoals
            .where((goal) => goal.category == event.category)
            .toList();
            
        emit(GoalsLoaded(
          allGoals: currentState.allGoals,
          filteredGoals: filteredGoals,
          selectedCategory: event.category,
        ));
      }
    }
  }
}