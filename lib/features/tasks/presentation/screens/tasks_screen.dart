import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:goals_gamification_app/core/models/task.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_bloc.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_state.dart';
import 'package:goals_gamification_app/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:goals_gamification_app/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:goals_gamification_app/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:goals_gamification_app/features/tasks/widgets/task_item.dart';
import 'package:uuid/uuid.dart';

class TasksScreen extends StatefulWidget {
  final String? goalId;

  const TasksScreen({
    Key? key,
    this.goalId,
  }) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      print('Loading tasks for user: ${authState.user.id}'); // 02.05 - 23:25
      context.read<TasksBloc>().add(
            LoadTasks(authState.user.id, goalId: widget.goalId),
          );
    }
  }

void _showAddTaskDialog() {
  final authState = context.read<AuthBloc>().state;
  final tasksState = context.read<TasksBloc>().state;
  
  if (authState is Authenticated && tasksState is TasksLoaded) {
    showDialog(
      context: context,
      builder: (_) => AddTaskDialog(
        userId: authState.user.id,
        goalId: widget.goalId ?? (tasksState.relatedGoal?.id ?? ''),
      ),
    ).then((_) {
      print('Діалог закрито, перезавантажуємо завдання');
      _loadTasks();
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<TasksBloc, TasksState>(
          builder: (context, state) {
            if (state is TasksLoaded && state.relatedGoal != null) {
              return Text('Завдання: ${state.relatedGoal!.title}');
            }
            return const Text('Всі завдання');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go('/');
          }
        },
        child: BlocBuilder<TasksBloc, TasksState>(
          builder: (context, state) {
            if (state is TasksLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TasksLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  _loadTasks();
                },
                child: state.filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('У вас немає завдань'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _showAddTaskDialog,
                              child: const Text('Додати завдання'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = state.filteredTasks[index];
                          print('Відображається завдання: ${task.id} - ${task.title}');
                          return TaskItem(
                            key: ValueKey(task.id),
                            task: task,
                            onTap: () {
                              _showTaskDetailDialog(task);
                            },
                            onCheckboxChanged: (isChecked) {
                              if (isChecked && !task.isCompleted) {
                                context.read<TasksBloc>().add(CompleteTask(task.id));
                              } else if (!isChecked && task.isCompleted) {
                                // Uncomplete task
                                final updatedTask = task.copyWith(isCompleted: false);
                                context.read<TasksBloc>().add(UpdateTask(updatedTask));
                              }
                            },
                            onDelete: () {
                              _showDeleteConfirmation(task);
                            },
                          );
                        },
                      ),
              );
            } else if (state is TasksError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Помилка: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadTasks,
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
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
              context.push('/goals');
              break;
            case 2:
              break; 
          }
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Фільтрувати за статусом'),
        content: BlocBuilder<TasksBloc, TasksState>(
          builder: (context, state) {
            if (state is TasksLoaded) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Всі завдання'),
                    leading: const Icon(Icons.list),
                    selected: state.filterIsCompleted == null,
                    onTap: () {
                      context.read<TasksBloc>().add(const FilterTasksByStatus(null));
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: const Text('Активні'),
                    leading: const Icon(Icons.check_box_outline_blank),
                    selected: state.filterIsCompleted == false,
                    onTap: () {
                      context.read<TasksBloc>().add(const FilterTasksByStatus(false));
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: const Text('Завершені'),
                    leading: const Icon(Icons.check_box),
                    selected: state.filterIsCompleted == true,
                    onTap: () {
                      context.read<TasksBloc>().add(const FilterTasksByStatus(true));
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _showTaskDetailDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.description.isNotEmpty) ...[
                const Text(
                  'Опис:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(task.description),
                const SizedBox(height: 16),
              ],
              const Text(
                'Пріоритет:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: task.priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(_getPriorityName(task.priority)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Дедлайн:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                task.deadline != null
                    ? '${task.deadline!.day}.${task.deadline!.month}.${task.deadline!.year} ${task.deadline!.hour}:${task.deadline!.minute.toString().padLeft(2, '0')}'
                    : 'Не вказано',
              ),
              const SizedBox(height: 16),
              const Text(
                'Статус:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                task.isCompleted ? 'Завершено' : 'Активне',
                style: TextStyle(
                  color: task.isCompleted ? Colors.green : null,
                  fontWeight: task.isCompleted ? FontWeight.bold : null,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрити'),
          ),
          if (!task.isCompleted)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<TasksBloc>().add(CompleteTask(task.id));
              },
              child: const Text('Завершити'),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити завдання?'),
        content: Text('Ви впевнені, що хочете видалити завдання "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TasksBloc>().add(DeleteTask(task.id));
            },
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }

  String _getPriorityName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Низький';
      case TaskPriority.medium:
        return 'Середній';
      case TaskPriority.high:
        return 'Високий';
    }
  }
}

class AddTaskDialog extends StatefulWidget {
  final String userId;
  final String goalId;
  final Task? taskToEdit;

  const AddTaskDialog({
    Key? key,
    required this.userId,
    required this.goalId,
    this.taskToEdit,
  }) : super(key: key);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _deadline;
  TimeOfDay? _deadlineTime;
  TaskPriority _priority = TaskPriority.medium;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descriptionController.text = widget.taskToEdit!.description;
      
      if (widget.taskToEdit!.deadline != null) {
        _deadline = widget.taskToEdit!.deadline!;
        _deadlineTime = TimeOfDay(
          hour: widget.taskToEdit!.deadline!.hour,
          minute: widget.taskToEdit!.deadline!.minute,
        );
      }
      
      _priority = widget.taskToEdit!.priority;
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
    final isEditing = widget.taskToEdit != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Редагувати завдання' : 'Додати нове завдання'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Назва завдання',
                  hintText: 'Введіть назву завдання',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть назву завдання';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Опис',
                  hintText: 'Опишіть ваше завдання',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Пріоритет'),
                trailing: DropdownButton<TaskPriority>(
                  value: _priority,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _priority = value;
                      });
                    }
                  },
                  items: TaskPriority.values.map((priority) {
                    return DropdownMenuItem<TaskPriority>(
                      value: priority,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(priority),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_getPriorityName(priority)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              ListTile(
                title: const Text('Дата'),
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
                            _deadlineTime = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
              if (_deadline != null)
                ListTile(
                  title: const Text('Час'),
                  subtitle: _deadlineTime != null
                      ? Text('${_deadlineTime!.hour}:${_deadlineTime!.minute.toString().padLeft(2, '0')}')
                      : const Text('Не вказано'),
                  trailing: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _deadlineTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _deadlineTime = time;
                        });
                      }
                    },
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
          onPressed: _saveTask,
          child: Text(isEditing ? 'Зберегти' : 'Додати'),
        ),
      ],
    );
  }

  String _getPriorityName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Низький';
      case TaskPriority.medium:
        return 'Середній';
      case TaskPriority.high:
        return 'Високий';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

Future<void> _saveTask() async {
  if (_formKey.currentState?.validate() ?? false) {
    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      
      // Combine date and time
      DateTime? finalDeadline;
      if (_deadline != null) {
        if (_deadlineTime != null) {
          finalDeadline = DateTime(
            _deadline!.year,
            _deadline!.month,
            _deadline!.day,
            _deadlineTime!.hour,
            _deadlineTime!.minute,
          );
        } else {
          finalDeadline = _deadline;
        }
      }
      
      if (widget.taskToEdit == null) {
        // Add new task
        final task = Task(
          id: const Uuid().v4(),
          userId: widget.userId,
          goalId: widget.goalId,
          title: title,
          description: description,
          createdAt: DateTime.now(),
          deadline: finalDeadline,
          priority: _priority,
          isCompleted: false,
        );
        
        print('Додавання нового завдання: ${task.title}');
        context.read<TasksBloc>().add(AddTask(task));
        print('Завдання додано до блоку');
      } else {
        // Update existing task
        final updatedTask = widget.taskToEdit!.copyWith(
          title: title,
          description: description,
          deadline: finalDeadline,
          priority: _priority,
        );
        
        print('Оновлення завдання: ${updatedTask.title}');
        context.read<TasksBloc>().add(UpdateTask(updatedTask));
      }
      
      Navigator.of(context).pop();
    } catch (e) {
      print('Помилка при збереженні завдання: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: $e')),
      );
    }
  }
}

}