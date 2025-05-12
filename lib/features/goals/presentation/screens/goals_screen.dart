import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:goals_gamification_app/core/models/goal.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_bloc.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_state.dart';
import 'package:goals_gamification_app/features/goals/presentation/bloc/goals_bloc.dart';
import 'package:goals_gamification_app/features/goals/presentation/bloc/goals_event.dart';
import 'package:goals_gamification_app/features/goals/presentation/bloc/goals_state.dart';
import 'package:goals_gamification_app/features/goals/presentation/screens/completed_goals_screen.dart';
import 'package:goals_gamification_app/features/goals/widgets/goal_item.dart';
import 'package:uuid/uuid.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

void _loadGoals() {
  final authState = context.read<AuthBloc>().state;
  if (authState is Authenticated) {
    // Завантажуємо всі цілі
    context.read<GoalsBloc>().add(LoadGoals(authState.user.id));
    
    // Після завантаження відфільтровуємо лише активні цілі
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        final goalsState = context.read<GoalsBloc>().state;
        if (goalsState is GoalsLoaded) {
          // Застосовуємо фільтр для відображення лише незавершених цілей
          context.read<GoalsBloc>().add(const FilterGoalsByStatus(false));
        }
      }
    });
  }
}

  void _showAddGoalDialog() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      showDialog(
        context: context,
        builder: (_) => AddGoalDialog(userId: authState.user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text('Мої цілі'),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            _showFilterDialog();
          },
        ),
        IconButton(
          icon: const Icon(Icons.done_all),
          tooltip: 'Завершені цілі',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CompletedGoalsScreen(),
              ),
            );
          },
        ),
      ],
    ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go('/');
          }
        },
        child: BlocBuilder<GoalsBloc, GoalsState>(
          builder: (context, state) {
            if (state is GoalsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GoalsLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  _loadGoals();
                },
                child: state.filteredGoals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('У вас ще немає цілей'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _showAddGoalDialog,
                              child: const Text('Додати першу ціль'),
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
                              // TODO: Navigate to goal details
                            },
                            onComplete: () {
                              context.read<GoalsBloc>().add(CompleteGoal(goal.id));
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
                      onPressed: _loadGoals,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
              context.push('/dashboard');
              break;
            case 1:
              break; // Already on Goals
            case 2:
              context.push('/tasks');
              break;
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити ціль?'),
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(),
    );
  }
}

class FilterDialog extends StatelessWidget {
  const FilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Фільтрувати за категорією'),
      content: BlocBuilder<GoalsBloc, GoalsState>(
        builder: (context, state) {
          if (state is GoalsLoaded) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Всі категорії'),
                  leading: const Icon(Icons.category),
                  selected: state.selectedCategory == null,
                  onTap: () {
                    context.read<GoalsBloc>().add(const FilterGoalsByCategory(null));
                    Navigator.of(context).pop();
                  },
                ),
                ...GoalCategory.values.map((category) => ListTile(
                      title: Text(_getCategoryName(category)),
                      leading: Icon(_getCategoryIcon(category)),
                      selected: state.selectedCategory == category,
                      onTap: () {
                        context.read<GoalsBloc>().add(FilterGoalsByCategory(category));
                        Navigator.of(context).pop();
                      },
                    )),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  String _getCategoryName(GoalCategory category) {
    switch (category) {
      case GoalCategory.personal:
        return 'Особисте';
      case GoalCategory.work:
        return 'Робота';
      case GoalCategory.education:
        return 'Навчання';
      case GoalCategory.health:
        return 'Здоров\'я';
      case GoalCategory.finance:
        return 'Фінанси';
      case GoalCategory.other:
        return 'Інше';
    }
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.personal:
        return Icons.person;
      case GoalCategory.work:
        return Icons.work;
      case GoalCategory.education:
        return Icons.school;
      case GoalCategory.health:
        return Icons.favorite;
      case GoalCategory.finance:
        return Icons.attach_money;
      case GoalCategory.other:
        return Icons.category;
    }
  }
}

class AddGoalDialog extends StatefulWidget {
  final String userId;
  final Goal? goalToEdit;

  const AddGoalDialog({
    super.key,
    required this.userId,
    this.goalToEdit,
  });

  @override
  _AddGoalDialogState createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _deadline;
  GoalPriority _priority = GoalPriority.medium;
  GoalCategory _category = GoalCategory.other;

  @override
  void initState() {
    super.initState();
    if (widget.goalToEdit != null) {
      _titleController.text = widget.goalToEdit!.title;
      _descriptionController.text = widget.goalToEdit!.description;
      _deadline = widget.goalToEdit!.deadline;
      _priority = widget.goalToEdit!.priority;
      _category = widget.goalToEdit!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.goalToEdit == null ? 'Додати нову ціль' : 'Редагувати ціль'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Назва цілі',
                  hintText: 'Введіть назву цілі',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть назву цілі';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Опис',
                  hintText: 'Опишіть вашу ціль',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Категорія'),
                trailing: DropdownButton<GoalCategory>(
                  value: _category,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _category = value;
                      });
                    }
                  },
                  items: GoalCategory.values.map((category) {
                    return DropdownMenuItem<GoalCategory>(
                      value: category,
                      child: Text(_getCategoryName(category)),
                    );
                  }).toList(),
                ),
              ),
              ListTile(
                title: const Text('Пріоритет'),
                trailing: DropdownButton<GoalPriority>(
                  value: _priority,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _priority = value;
                      });
                    }
                  },
                  items: GoalPriority.values.map((priority) {
                    return DropdownMenuItem<GoalPriority>(
                      value: priority,
                      child: Text(_getPriorityName(priority)),
                    );
                  }).toList(),
                ),
              ),
              ListTile(
                title: const Text('Дедлайн'),
                subtitle: _deadline != null
                    ? Text('${_deadline!.day}.${_deadline!.month}.${_deadline!.year}')
                    : const Text('Не вказано'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _deadline ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (date != null) {
                          setState(() {
                            _deadline = date;
                          });
                        }
                      },
                    ),
                    if (_deadline != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _deadline = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
        ElevatedButton(
          onPressed: _saveGoal,
          child: Text(widget.goalToEdit == null ? 'Додати' : 'Зберегти'),
        ),
      ],
    );
  }

  String _getCategoryName(GoalCategory category) {
    switch (category) {
      case GoalCategory.personal:
        return 'Особисте';
      case GoalCategory.work:
        return 'Робота';
      case GoalCategory.education:
        return 'Навчання';
      case GoalCategory.health:
        return 'Здоров\'я';
      case GoalCategory.finance:
        return 'Фінанси';
      case GoalCategory.other:
        return 'Інше';
    }
  }

  String _getPriorityName(GoalPriority priority) {
    switch (priority) {
      case GoalPriority.low:
        return 'Низький';
      case GoalPriority.medium:
        return 'Середній';
      case GoalPriority.high:
        return 'Високий';
    }
  }

  void _saveGoal() {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      
      if (widget.goalToEdit == null) {
        // Add new goal
        final goal = Goal(
          id: const Uuid().v4(),
          userId: widget.userId,
          title: title,
          description: description,
          createdAt: DateTime.now(),
          deadline: _deadline,
          priority: _priority,
          category: _category,
        );
        
        context.read<GoalsBloc>().add(AddGoal(goal));
      } else {
        // Update existing goal
        final updatedGoal = widget.goalToEdit!.copyWith(
          title: title,
          description: description,
          deadline: _deadline,
          priority: _priority,
          category: _category,
        );
        
        context.read<GoalsBloc>().add(UpdateGoal(updatedGoal));
      }
      
      Navigator.of(context).pop();
    }
  }
}