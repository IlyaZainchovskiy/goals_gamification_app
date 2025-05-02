import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_bloc.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_state.dart';
import 'package:goals_gamification_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:goals_gamification_app/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:goals_gamification_app/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:goals_gamification_app/features/dashboard/widgets/daily_progress.dart';
import 'package:goals_gamification_app/features/dashboard/widgets/upcoming_tasks.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<DashboardBloc>().add(LoadDashboardData(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваш прогрес'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go('/');
          }
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  _loadDashboardData();
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DailyProgress(
                        completedTasks: state.completedTasksToday,
                        totalTasks: state.todayTasks.length,
                        xp: state.user.xp,
                        level: state.user.level,
                      ),
                      const SizedBox(height: 24),
                      UpcomingTasks(
                        tasks: state.todayTasks,
                        onTaskTap: (task) {
                          // TODO: Implement task detail view
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Найближчі цілі',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (state.upcomingGoals.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text('Немає найближчих цілей'),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.upcomingGoals.length,
                          itemBuilder: (context, index) {
                            final goal = state.upcomingGoals[index];
                            return ListTile(
                              leading: Icon(goal.categoryIcon),
                              title: Text(goal.title),
                              subtitle: goal.deadline != null
                                  ? Text('До ${goal.deadline!.day}.${goal.deadline!.month}.${goal.deadline!.year}')
                                  : null,
                              trailing: Text('${goal.progress}%'),
                              onTap: () {
                                // TODO: Navigate to goal details
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            } else if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Помилка: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDashboardData,
                      child: const Text('Спробувати знову'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Головна',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Цілі',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Завдання',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break; // Already on Dashboard
            case 1:
              context.push('/goals');
              break;
            case 2:
              context.push('/tasks');
              break;
          }
        },
      ),
    );
  }
}