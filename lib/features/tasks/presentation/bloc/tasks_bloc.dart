import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goals_gamification_app/core/models/task.dart';
import 'package:goals_gamification_app/data/repositories/achievement_repository.dart';
import 'package:goals_gamification_app/data/repositories/goal_repository.dart';
import 'package:goals_gamification_app/data/repositories/task_repository.dart';
import 'package:goals_gamification_app/data/repositories/user_repository.dart';
import 'package:goals_gamification_app/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:goals_gamification_app/features/tasks/presentation/bloc/tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository _taskRepository;
  final GoalRepository _goalRepository;
  final UserRepository _userRepository;
  final AchievementRepository _achievementRepository;

  TasksBloc(this._achievementRepository, {
    required TaskRepository taskRepository,
    required GoalRepository goalRepository,
    required UserRepository userRepository,
  })  : _taskRepository = taskRepository,
        _goalRepository = goalRepository,
        _userRepository = userRepository,
        super(TasksInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<CompleteTask>(_onCompleteTask);
    on<FilterTasksByStatus>(_onFilterTasksByStatus);
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TasksState> emit,
  ) async {
    emit(TasksLoading());
    try {
      final List<Task> tasks;
      final goal = event.goalId != null 
          ? await _goalRepository.getGoal(event.goalId!) 
          : null;
      
      if (event.goalId != null) {
        // Load tasks for specific goal
        tasks = await _taskRepository.getTasksByGoal(event.goalId!);
      } else {
        // Load all user tasks
        tasks = await _taskRepository.getTasksByUser(event.userId);
      }
      
      emit(TasksLoaded(
        allTasks: tasks,
        filteredTasks: tasks,
        relatedGoal: goal,
      ));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> _onAddTask(
  AddTask event,
  Emitter<TasksState> emit,
) async {
  final currentState = state;
  if (currentState is TasksLoaded) {
    try {
      final taskId = await _taskRepository.createTask(event.task);
      
      final newTask = event.task.copyWith(id: taskId);
      
      final updatedAllTasks = List<Task>.from(currentState.allTasks)..add(newTask);
      
      List<Task> updatedFilteredTasks = updatedAllTasks;
      if (currentState.filterIsCompleted != null) {
        updatedFilteredTasks = updatedAllTasks
            .where((task) => task.isCompleted == currentState.filterIsCompleted)
            .toList();
      }
      
      emit(TasksLoaded(
        allTasks: updatedAllTasks,
        filteredTasks: updatedFilteredTasks,
        relatedGoal: currentState.relatedGoal,
        filterIsCompleted: currentState.filterIsCompleted,
      ));
      
      // Додаємо XP за створення завдання
      await _userRepository.addXp(event.task.userId, 2);
    } catch (e) {
      print('Помилка при додаванні завдання: $e');
      emit(TasksError(e.toString()));
    }
  }
}

  Future<void> _onUpdateTask(
    UpdateTask event,
    Emitter<TasksState> emit,
  ) async {
    final currentState = state;
    if (currentState is TasksLoaded) {
      try {
        await _taskRepository.updateTask(event.task);
        
        final taskIndex = currentState.allTasks.indexWhere((t) => t.id == event.task.id);
        if (taskIndex != -1) {
          final updatedTasks = List<Task>.from(currentState.allTasks);
          updatedTasks[taskIndex] = event.task;
          
          List<Task> filteredTasks = updatedTasks;
          if (currentState.filterIsCompleted != null) {
            filteredTasks = updatedTasks.where((task) => 
                task.isCompleted == currentState.filterIsCompleted).toList();
          }
          
          emit(TasksLoaded(
            allTasks: updatedTasks,
            filteredTasks: filteredTasks,
            relatedGoal: currentState.relatedGoal,
            filterIsCompleted: currentState.filterIsCompleted,
          ));
        }
      } catch (e) {
        emit(TasksError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<TasksState> emit,
  ) async {
    final currentState = state;
    if (currentState is TasksLoaded) {
      try {
        await _taskRepository.deleteTask(event.taskId);
        
        final updatedTasks = currentState.allTasks.where((t) => t.id != event.taskId).toList();
        
        List<Task> filteredTasks = updatedTasks;
        if (currentState.filterIsCompleted != null) {
          filteredTasks = updatedTasks.where((task) => 
              task.isCompleted == currentState.filterIsCompleted).toList();
        }
        
        emit(TasksLoaded(
          allTasks: updatedTasks,
          filteredTasks: filteredTasks,
          relatedGoal: currentState.relatedGoal,
          filterIsCompleted: currentState.filterIsCompleted,
        ));
      } catch (e) {
        emit(TasksError(e.toString()));
      }
    }
  }

  Future<void> _onCompleteTask(
  CompleteTask event,
  Emitter<TasksState> emit,
) async {
  final currentState = state;
  if (currentState is TasksLoaded) {
    try {
      final task = currentState.allTasks.firstWhere((t) => t.id == event.taskId);
      
      await _taskRepository.completeTask(event.taskId);
      
      final taskIndex = currentState.allTasks.indexWhere((t) => t.id == event.taskId);
      if (taskIndex != -1) {
        final updatedTasks = List<Task>.from(currentState.allTasks);
        updatedTasks[taskIndex] = updatedTasks[taskIndex].copyWith(isCompleted: true);
        
        List<Task> filteredTasks = updatedTasks;
        if (currentState.filterIsCompleted != null) {
          filteredTasks = updatedTasks.where((task) => 
              task.isCompleted == currentState.filterIsCompleted).toList();
        }
        
        emit(TasksLoaded(
          allTasks: updatedTasks,
          filteredTasks: filteredTasks,
          relatedGoal: currentState.relatedGoal,
          filterIsCompleted: currentState.filterIsCompleted,
        ));
        
        await _userRepository.addXp(task.userId, 5, context: event.context);
        
        // Перевірка досягнення з передачею контексту
        if (event.context != null) {
          await _achievementRepository.checkAndAwardAchievements(
            task.userId, 
            event.context!,
          );
        }
      }
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }
}

  void _onFilterTasksByStatus(
    FilterTasksByStatus event,
    Emitter<TasksState> emit,
  ) {
    final currentState = state;
    if (currentState is TasksLoaded) {
      if (event.isCompleted == null) {
        emit(TasksLoaded(
          allTasks: currentState.allTasks,
          filteredTasks: currentState.allTasks,
          relatedGoal: currentState.relatedGoal,
          filterIsCompleted: null,
        ));
      } else {
        final filteredTasks = currentState.allTasks
            .where((task) => task.isCompleted == event.isCompleted)
            .toList();
            
        emit(TasksLoaded(
          allTasks: currentState.allTasks,
          filteredTasks: filteredTasks,
          relatedGoal: currentState.relatedGoal,
          filterIsCompleted: event.isCompleted,
        ));
      }
    }
  }
}