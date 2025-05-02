import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goals_gamification_app/core/models/goal.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_bloc.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_state.dart';
import 'package:goals_gamification_app/features/goals/presentation/bloc/goals_bloc.dart';
import 'package:goals_gamification_app/features/goals/presentation/bloc/goals_event.dart';
import 'package:goals_gamification_app/features/goals/presentation/bloc/goals_state.dart';
import 'package:goals_gamification_app/features/goals/widgets/goal_item.dart';

class CompletedGoalsScreen extends StatefulWidget {
  const CompletedGoalsScreen({Key? key}) : super(key: key);

  @override
  _CompletedGoalsScreenState createState() => _CompletedGoalsScreenState();
}

class _CompletedGoalsScreenState extends State<CompletedGoalsScreen> {
  @override
  void initState() {
    super.initState();
    _loadCompletedGoals();
  }

  void _loadCompletedGoals() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      // Завантажуємо всі цілі
      context.read<GoalsBloc>().add(LoadGoals(authState.user.id));
      
      // Відфільтровуємо тільки завершені
      context.read<GoalsBloc>().add(const FilterGoalsByStatus(true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Завершені цілі'),
      ),
      body: BlocBuilder<GoalsBloc, GoalsState>(
        builder: (context, state) {
          if (state is GoalsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GoalsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                _loadCompletedGoals();
              },
              child: state.filteredGoals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('У вас немає завершених цілей'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Повернутися до активних цілей'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.filteredGoals.length,
                      itemBuilder: (context, index) {
                        final goal = state.filteredGoals[index];
                        return GoalItem(
                          goal: goal,
                          onTap: () {
                            // Переглянути деталі цілі
                          },
                          onDelete: () {
                            _showDeleteConfirmation(goal);
                          },
                        );
                      },
                    ),
            );
          } else if (state is GoalsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Помилка: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCompletedGoals,
                    child: const Text('Спробувати знову'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showDeleteConfirmation(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити завершену ціль?'),
        content: Text('Ви впевнені, що хочете видалити ціль "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<GoalsBloc>().add(DeleteGoal(goal.id));
            },
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }
}