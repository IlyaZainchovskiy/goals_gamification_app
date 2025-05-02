import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goals_gamification_app/data/repositories/goal_repository.dart';
import 'package:goals_gamification_app/data/repositories/task_repository.dart';
import 'package:goals_gamification_app/data/repositories/user_repository.dart';
import 'package:goals_gamification_app/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:goals_gamification_app/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final UserRepository _userRepository;
  final GoalRepository _goalRepository;
  final TaskRepository _taskRepository;

  DashboardBloc({
    required UserRepository userRepository,
    required GoalRepository goalRepository,
    required TaskRepository taskRepository,
  })  : _userRepository = userRepository,
        _goalRepository = goalRepository,
        _taskRepository = taskRepository,
        super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final user = await _userRepository.getUser(event.userId);
      
      if (user != null) {
        final todayTasks = await _taskRepository.getTodayTasks(event.userId);
        final upcomingGoals = await _goalRepository.getUpcomingGoals(event.userId);
        
        final allTasks = await _taskRepository.getTasksByUser(event.userId);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        final completedTasksToday = allTasks.where((task) => 
          task.isCompleted && 
          DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day)
              .isAtSameMomentAs(today)
        ).length;
        
        emit(DashboardLoaded(
          user: user,
          todayTasks: todayTasks,
          upcomingGoals: upcomingGoals,
          completedTasksToday: completedTasksToday,
        ));
      } else {
        emit(const DashboardError('Користувача не знайдено'));
      }
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}